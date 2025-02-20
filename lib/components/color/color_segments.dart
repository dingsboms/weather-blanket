import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/color/color_picker_box.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/models/range_interval.dart';

class ColorSegments extends ConsumerStatefulWidget {
  const ColorSegments({super.key, required this.userId});
  final String userId;

  @override
  ConsumerState<ColorSegments> createState() => _ColorSegmentsState();
}

class _ColorSegmentsState extends ConsumerState<ColorSegments> {
  // Define the list of range intervals
  List<RangeInterval> ranges = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
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

        setState(() {
          ranges = intervals;
        });
      } else {
        FirebaseFirestore.instance
            .collection("default_colors")
            .doc("bjS853oVmBtaa0NHwDqL")
            .get()
            .then((doc) {
          final List<dynamic> colorsData = doc.get('colors') as List<dynamic>;
          final List<RangeInterval> intervals = colorsData
              .map((data) =>
                  RangeInterval.fromFirestore(data as Map<String, dynamic>))
              .toList();

          setState(() {
            ranges = intervals;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ranges.isEmpty) {
      return const CupertinoActivityIndicator();
    }
    // Convert list to map for the segmented control
    List<Widget> widgetChildren = [];
    ranges.sort((a, b) => a.minTemp.compareTo(b.minTemp));

    // Populate segmentChildren with Widgets
    for (var i = 0; i < ranges.length; i++) {
      final interval = ranges[i];
      widgetChildren.add(
        SizedBox(
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
                          !interval.maxTemp.isNegative
                              ? "+${interval.minTemp}"
                              : interval.minTemp.toString(),
                          style: const TextStyle(color: CupertinoColors.white),
                        )),
                    Visibility(
                        visible: i != ranges.length - 1,
                        child: Text(
                            !interval.maxTemp.isNegative
                                ? "+${interval.maxTemp}"
                                : interval.maxTemp.toString(),
                            style:
                                const TextStyle(color: CupertinoColors.white)))
                  ],
                ),
              ),
              ColorPickerBox(
                rangeInterval: interval,
                onUpdate: (pickedColor) async {
                  interval.color = pickedColor;
                  updateColors(widget.userId, ranges);
                },
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          // Use Row instead of Wrap for horizontal layout
          children: widgetChildren
              .map((widget) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: widget,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<void> updateColors(String userId, List<RangeInterval> colors) async {
    final intervalsFirestoreList =
        colors.map((interval) => interval.toFiretore());

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set({"colors": intervalsFirestoreList}, SetOptions(merge: true));
    ref.invalidate(colorRangesProvider);
  }
}
