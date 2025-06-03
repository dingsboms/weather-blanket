import 'package:flutter/cupertino.dart';

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
            currentColor.withValues(alpha: 0.69),
            currentColor,
            currentColor.withValues(alpha: 0.69),
          ],
        ),
        border: Border.all(color: CupertinoColors.black),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
