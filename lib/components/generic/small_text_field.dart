import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

final BoxDecoration textFieldDecoration = BoxDecoration(
  color: CupertinoColors.white,
  border: Border.all(color: CupertinoColors.black.withOpacity(0.5), width: 1.0),
  borderRadius: BorderRadius.circular(5.0),
);

const TextStyle textStyle = TextStyle(color: CupertinoColors.black);

class SmallTextField extends StatelessWidget {
  const SmallTextField(
      {super.key,
      required this.controller,
      this.formatters,
      this.keyboardType});
  final TextEditingController controller;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: CupertinoTextField(
        controller: controller,
        style: textStyle,
        keyboardType: keyboardType,
        decoration: textFieldDecoration,
        cursorColor: CupertinoColors.black,
        inputFormatters: formatters,
      ),
    );
  }
}
