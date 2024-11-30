import 'package:flutter/material.dart';

class ColorRow extends StatelessWidget {
  final List<Color> colors;
  final double height;

  const ColorRow({
    super.key,
    required this.colors,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final segmentWidth = totalWidth / colors.length;

          return Row(
            children: colors
                .map(
                  (color) => Container(
                    width: segmentWidth,
                    color: color,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
