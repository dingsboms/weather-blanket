import 'package:flutter/material.dart';

class ToggleHomePageButton extends StatelessWidget {
  const ToggleHomePageButton({
    super.key,
    required this.editMode,
    required this.onToggle,
  });

  final bool editMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon:
          editMode ? const Icon(Icons.list_alt_sharp) : const Icon(Icons.list),
    );
  }
}
