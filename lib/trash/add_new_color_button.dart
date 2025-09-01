import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddNewColorButton extends StatelessWidget {
  const AddNewColorButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      color: CupertinoColors.systemCyan.withAlpha(150),
      child: const Icon(Icons.add),
    );
  }
}
