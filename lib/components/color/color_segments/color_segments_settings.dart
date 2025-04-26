import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_blanket/components/color/color_picker_box.dart';
import 'package:weather_blanket/components/color/color_segments/color_segments.dart';

class ColorSegmentsSettings extends StatefulWidget {
  const ColorSegmentsSettings({super.key});

  @override
  State<ColorSegmentsSettings> createState() => _ColorSegmentsSettingsState();
}

class _ColorSegmentsSettingsState extends State<ColorSegmentsSettings> {
  @override
  Widget build(BuildContext context) {
    return ColorSegments(
      segmentBuilder:
          (context, interval, onUpdate, onDelete, intervalsOverlap) =>
              ColorPickerBox(
        key: ValueKey(
            'picker-${interval.minTemp}-${interval.maxTemp}-${interval.color.toARGB32()}'),
        rangeInterval: interval,
        onUpdate: (pickedColor) async {
          setState(() {
            interval.color = pickedColor;
          });
          await onUpdate();
        },
        onDelete: () async => await onDelete(),
        intervalsOverlap: intervalsOverlap,
      ),
    );
  }
}
