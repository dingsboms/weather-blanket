import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const TextStyle textStyle = TextStyle(color: CupertinoColors.black);

class SmallTextField extends StatelessWidget {
  const SmallTextField({
    super.key,
    required this.controller,
    this.formatters,
    this.keyboardType,
  });

  final TextEditingController controller;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: TextField(
        controller: controller,
        style: textStyle,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: CupertinoColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              color: CupertinoColors.black,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              color: CupertinoColors.black,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              color: CupertinoColors.black,
              width: 1.0,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        cursorColor: CupertinoColors.black,
        inputFormatters: formatters,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
