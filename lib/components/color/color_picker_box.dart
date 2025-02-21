import 'package:flutter/material.dart';
import 'package:weather_blanket/components/color/color_picker_dialog.dart';
import 'package:weather_blanket/models/range_interval.dart';

// Updated original widget
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
            return ColorPickerDialog(
              initialColor: currentColor,
              rangeInterval: widget.rangeInterval,
              onUpdate: (pickedColor) async {
                setState(() {
                  currentColor = pickedColor;
                });
                await widget.onUpdate(pickedColor);
              },
              onDelete: widget.onDelete,
              intervalsOverlap: widget.intervalsOverlap,
            );
          },
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: currentColor,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
