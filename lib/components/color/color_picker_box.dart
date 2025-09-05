import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// A simple, reusable color picker box for picking a single color.
/// Pops up a dialog with a color wheel and returns the picked color.
class ColorPickerBox extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorPicked;
  final double size;
  final String? dialogTitle;
  final VoidCallback? onDelete;

  const ColorPickerBox({
    super.key,
    required this.currentColor,
    required this.onColorPicked,
    this.size = 100,
    this.dialogTitle,
    this.onDelete,
  });

  Future<void> _pickColor(BuildContext context) async {
    Color tempColor = currentColor;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle ?? 'Pick Color'),
        content: SizedBox(
          width: 220,
          height: 240,
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            paletteType: PaletteType.hueWheel,
            enableAlpha: false,
            displayThumbColor: true,
            portraitOnly: true,
            colorPickerWidth: 200,
            pickerAreaHeightPercent: 0.75,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
              onPressed: onDelete,
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              )),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onColorPicked(tempColor);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickColor(context),
      child: Container(
        width: size,
        height: size,
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
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
