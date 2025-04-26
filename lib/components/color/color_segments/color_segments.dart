import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/color/add_new_color_button.dart';
import 'package:weather_blanket/components/color/color_segments/functions/add_new_range_interval.dart';
import 'package:weather_blanket/components/color/color_segments/functions/delete_range_interval.dart';
import 'package:weather_blanket/components/color/color_segments/functions/gap_in_intervals.dart';
import 'package:weather_blanket/components/color/color_segments/functions/intervals_overlap.dart';
import 'package:weather_blanket/components/color/color_segments/functions/update_colors.dart';
import 'package:weather_blanket/components/color/get_default_colors.dart';
import 'package:weather_blanket/models/range_interval.dart';

class ColorSegments extends ConsumerStatefulWidget {
  const ColorSegments(
      {super.key, required this.userId, required this.segmentBuilder});
  final String userId;
  final Widget Function(
      BuildContext context,
      RangeInterval interval,
      Future<void> Function() onUpdate,
      Future<void> Function() onDelete,
      bool Function() intervalsOverlap) segmentBuilder;
  @override
  ConsumerState<ColorSegments> createState() => _ColorSegmentsState();
}

class _ColorSegmentsState extends ConsumerState<ColorSegments> {
  // Define the list of range intervals
  List<RangeInterval> ranges = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchColorRanges();
  }

  Future<void> _fetchColorRanges() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get()
        .then((doc) {
      if (doc.exists && doc.data()!.containsKey('colors')) {
        final List<dynamic> colorsData = doc.get('colors') as List<dynamic>;
        final List<RangeInterval> intervals = colorsData
            .map((data) =>
                RangeInterval.fromFirestore(data as Map<String, dynamic>))
            .toList();

        intervals.sort((a, b) => a.minTemp.compareTo(b.minTemp));

        setState(() {
          ranges = intervals;
          isLoading = false;
        });
      } else {
        fetchDefaultColors();
      }
    });
  }

  fetchDefaultColors() async {
    List<RangeInterval> intervals = await getDefaultColors();

    setState(() {
      ranges = intervals;
      isLoading = false;
    });
    await updateColors(ranges, ref);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CupertinoActivityIndicator();
    }

    // Make a new copy of the ranges list for the build method
    final currentRanges = List<RangeInterval>.from(ranges);
    currentRanges.sort((a, b) => a.minTemp.compareTo(b.minTemp));

    List<Widget> widgetChildren = [];

    for (var i = 0; i < currentRanges.length; i++) {
      final interval = currentRanges[i];

      widgetChildren.add(
        SizedBox(
          key: ValueKey(
              '${interval.minTemp}-${interval.maxTemp}-${interval.color.toARGB32()}'),
          width: 80,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                        visible: i != 0,
                        child: Text(
                          interval.minTemp.isNegative
                              ? interval.minTemp.toString()
                              : "+${interval.minTemp}",
                          style: const TextStyle(color: CupertinoColors.white),
                        )),
                    Visibility(
                        visible: i != currentRanges.length - 1,
                        child: Text(
                            interval.maxTemp.isNegative
                                ? interval.maxTemp.toString()
                                : "+${interval.maxTemp}",
                            style:
                                const TextStyle(color: CupertinoColors.white)))
                  ],
                ),
              ),
              widget.segmentBuilder(
                  context,
                  interval,
                  () => _handleUpdateRangeIntevalCallBack(interval),
                  () => _deleteInterval(interval),
                  () => intervalsOverlap(ranges)),
            ],
          ),
        ),
      );
    }

    widgetChildren.add(AddNewColorButton(
      onPressed: () async {
        ranges = await addNewRangeInterval(ranges, context);
        await updateColors(ranges, ref);
        setState(() {});
      },
    ));

    final (isGap, gap, from, to) = gapInIntervals(ranges);

    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widgetChildren
                  .map((widget) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: widget,
                      ))
                  .toList(),
            ),
          ),
          Visibility(
              visible: isGap,
              child: Text(
                  "Warning, Gap between ${from?.maxTemp.isNegative ?? false ? '${from?.maxTemp}' : '+${from?.maxTemp}'} and ${to?.minTemp.isNegative ?? false ? '${to?.minTemp}' : '+${to?.minTemp}'} on $gap ${gap == 1 ? 'degree' : 'degrees'}"))
        ],
      ),
    );
  }

  Future<void> _handleUpdateRangeIntevalCallBack(
      RangeInterval intervalToUpdate) async {
    setState(() async {
      await updateColors(ranges, ref);
    });
  }

  _deleteInterval(RangeInterval intervalToDelete) async {
    List<RangeInterval> newRanges =
        await deleteRangeInterval(intervalToDelete, ranges);

    ranges = newRanges;

    await updateColors(ranges, ref);

    setState(() {});
  }
}
