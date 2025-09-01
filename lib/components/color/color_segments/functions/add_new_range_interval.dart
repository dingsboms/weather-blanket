import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tempestry/components/color/interval_color_picker_dialog.dart';
import 'package:tempestry/models/range_interval.dart';

Future<List<RangeInterval>> addNewRangeInterval(
    List<RangeInterval> ranges, BuildContext context) async {
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

  ranges.add(newRange);

  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return IntervalColorPickerDialog(
          initialColor: newColor,
          onDelete: () async {
            ranges.remove(newRange);
          },
          intervalLabel: "${newRange.minTemp}° to ${newRange.maxTemp}°",
          onSubmit: (Color color) {
            newRange.color = color;
          },
        );
      });

  return ranges;
}
