import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/color/add_new_color_button.dart';
import 'package:weather_blanket/components/color/color_picker_box.dart';
import 'package:weather_blanket/components/color/color_picker_dialog.dart';
import 'package:weather_blanket/components/color/get_default_clors.dart';
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
    await updateColors(widget.userId, ranges);
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
              ColorPickerBox(
                key: ValueKey(
                    'picker-${interval.minTemp}-${interval.maxTemp}-${interval.color.toARGB32()}'),
                rangeInterval: interval,
                onUpdate: (pickedColor) async {
                  setState(() {
                    interval.color = pickedColor;
                  });
                  await updateColors(widget.userId, currentRanges);
                },
                onDelete: () async => await deleteRangeInterval(
                    widget.userId, interval, currentRanges),
                intervalsOverlap: () => intervalsOverlap(ranges),
              ),
            ],
          ),
        ),
      );
    }

    widgetChildren.add(AddNewColorButton(
      onPressed: () => addNewRangeInterval(ranges),
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

  bool intervalsOverlap(List<RangeInterval> ranges) {
    if (ranges.isEmpty || ranges.length == 1) {
      return false;
    }
    for (var i = 0; i < ranges.length - 1; i++) {
      RangeInterval currentInteval = ranges[i];
      RangeInterval nextInterval = ranges[i + 1];
      if (currentInteval.maxTemp >= nextInterval.minTemp) {
        return true;
      }
    }
    return false;
  }

  // isGap, sizeGap, fromInterval, toInterval
  (bool, int, RangeInterval?, RangeInterval?) gapInIntervals(
      List<RangeInterval> ranges) {
    if (ranges.isEmpty || ranges.length == 1) {
      return (false, 0, null, null);
    }
    for (var i = 0; i < ranges.length - 1; i++) {
      RangeInterval currentInteval = ranges[i];
      RangeInterval nextInterval = ranges[i + 1];
      int gap = nextInterval.minTemp - currentInteval.maxTemp;
      if (gap > 1) {
        return (true, gap - 1, currentInteval, nextInterval);
      }
    }
    return (false, 0, null, null);
  }

  // Returns success true / false
  Future<bool> updateColors(String userId, List<RangeInterval> colors) async {
    if (intervalsOverlap(colors)) {
      print('Intervals overlap detected');
      return false;
    }
    final intervalsFirestoreList =
        colors.map((interval) => interval.toFiretore()).toList();

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set({"colors": intervalsFirestoreList}, SetOptions(merge: true));
      print('Firestore update successful');
      ref.invalidate(colorRangesProvider);
      return true;
    } catch (e) {
      print('Error updating Firestore: $e');
      return false;
    }
  }

  Future<void> deleteRangeInterval(String userId,
      RangeInterval intervalToDelete, List<RangeInterval> currentRanges) async {
    final removeIndex = currentRanges.indexWhere((interval) =>
        interval.minTemp == intervalToDelete.minTemp &&
        interval.maxTemp == intervalToDelete.maxTemp);

    if (removeIndex != -1) {
      setState(() {
        final removedInterval = currentRanges.removeAt(removeIndex);

        // Get surrounding elements
        final elementBefore =
            removeIndex > 0 ? currentRanges[removeIndex - 1] : null;
        final elementAfter = removeIndex < currentRanges.length
            ? currentRanges[removeIndex]
            : null;

        final temperatureIntervalToFill =
            removedInterval.maxTemp - removedInterval.minTemp;

        for (var i = 0; i <= temperatureIntervalToFill; i++) {
          bool incrementElementBefore = i % 2 == 0;
          if (incrementElementBefore && elementBefore != null) {
            elementBefore.maxTemp += 1;
          } else if (!incrementElementBefore && elementAfter != null) {
            elementAfter.minTemp -= 1;
          }
        }

        elementBefore?.setInt();
        elementAfter?.setInt();

        ranges = List<RangeInterval>.from(currentRanges);
      });

      // Then update Firestore and invalidate provider
      await updateColors(userId, ranges);
    }
  }

  addNewRangeInterval(List<RangeInterval> ranges) {
    RangeInterval newRange;
    Color newColor = CupertinoColors.inactiveGray;
    if (ranges.isNotEmpty) {
      RangeInterval lastRange = ranges.last;
      if (lastRange.maxTemp == 100) {
        lastRange.maxTemp = lastRange.minTemp + 3;
        lastRange.setText();
      }

      newRange = RangeInterval(
          minTemp: lastRange.maxTemp + 1,
          maxTemp: lastRange.maxTemp + 4,
          color: newColor);

      newRange.setText();
    } else {
      newRange = RangeInterval(minTemp: -24, maxTemp: -20, color: newColor);
    }

    setState(() {
      ranges.add(newRange);
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ColorPickerDialog(
            initialColor: newColor,
            rangeInterval: newRange,
            onUpdate: (color) async {
              await updateColors(widget.userId, ranges);
              setState(() {
                newRange.color = color;
              });
            },
            onDelete: () async {
              setState(() {
                ranges.remove(newRange);
              });
            },
            intervalsOverlap: () => intervalsOverlap(ranges),
          );
        });
  }
}
