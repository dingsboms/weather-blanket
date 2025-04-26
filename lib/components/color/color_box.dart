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
        color: currentColor,
        border: Border.all(color: CupertinoColors.black),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
