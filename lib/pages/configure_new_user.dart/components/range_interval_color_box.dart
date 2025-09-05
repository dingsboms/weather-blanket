import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tempestry/components/color/color_picker_box.dart';
import 'package:tempestry/models/range_interval.dart';

class RangeIntervalColorBox extends StatelessWidget {
  final RangeInterval interval;
  final ValueChanged<Color> onColorPicked;
  final VoidCallback? onDelete;
  final double size;
  final String? intervalLabelOverride;

  const RangeIntervalColorBox({
    super.key,
    required this.interval,
    required this.onColorPicked,
    this.onDelete,
    this.size = 40,
    this.intervalLabelOverride,
  });

  // No longer needed: pickColorForInterval. Use ColorPickerBox directly.

  @override
  Widget build(BuildContext context) {
    return ColorPickerBox(
      currentColor: interval.color,
      onColorPicked: onColorPicked,
      onDelete: () {
        onDelete?.call();
        context.pop();
      },
      size: size,
      dialogTitle: intervalLabelOverride ??
          '${interval.minTemp}° to ${interval.maxTemp}°',
    );
  }
}
