import 'package:flutter/material.dart';
import 'package:tempestry/components/color/color_and_temperature_picker_dialog.dart';
import 'package:tempestry/components/color/color_box.dart';
import 'package:tempestry/models/range_interval.dart';

class ColorPickerBox extends StatefulWidget {
  const ColorPickerBox({
    super.key,
    required this.rangeInterval,
    required this.onUpdate,
    required this.onDelete,
    required this.intervalsOverlap,
  });

  final RangeInterval rangeInterval;
  final Future<void> Function(Color pickedColor) onUpdate;
  final Future<void> Function() onDelete;
  final bool Function() intervalsOverlap;

  @override
  State<ColorPickerBox> createState() => _ColorPickerBoxState();
}

class _ColorPickerBoxState extends State<ColorPickerBox> {
  late Color currentColor = widget.rangeInterval.color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ColorAndTemperaturePickerDialog(
              initialColor: currentColor,
              rangeInterval: widget.rangeInterval,
              onUpdate: (pickedColor) async {
                await widget.onUpdate(pickedColor);
              },
              onDelete: widget.onDelete,
              intervalsOverlap: widget.intervalsOverlap,
            );
          },
        );
      },
      child: ColorBox(currentColor: currentColor),
    );
  }
}
