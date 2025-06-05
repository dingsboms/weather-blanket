import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorBox extends StatelessWidget {
  const ColorBox({
    super.key,
    required this.currentColor,
  });

  final Color currentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(currentColor, Colors.white, 0.15)!,
            currentColor,
            currentColor,
            Color.lerp(currentColor, Colors.white, 0.15)!,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
        border: Border.all(color: CupertinoColors.black),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
