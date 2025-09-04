import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';

/// A lightweight color picker dialog tailored for selecting a color
/// for an existing slider interval. Interval bounds are displayed but
/// not editable here (they are controlled by the slider thumbs).
class IntervalColorPickerDialog extends StatefulWidget {
  const IntervalColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.intervalLabel,
    required this.onSubmit,
    required this.onDelete,
  });

  final Color initialColor;
  final String intervalLabel; // e.g. "-5 °C to 0 °C"
  final void Function(Color color) onSubmit;
  final VoidCallback onDelete;

  @override
  State<IntervalColorPickerDialog> createState() =>
      _IntervalColorPickerDialogState();
}

class _IntervalColorPickerDialogState extends State<IntervalColorPickerDialog> {
  late Color _selectedColor = widget.initialColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pick Color'),
              IconButton(
                  onPressed: () => context.pop(), icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.intervalLabel,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ],
      ),
      // Constrain the picker so the dialog isn't excessively tall.
      // Adjust height/width here as we iterate.
      content: SizedBox(
        width: 220,
        height: 240,
        child: ColorPicker(
          pickerColor: _selectedColor,
          onColorChanged: (c) => setState(() => _selectedColor = c),
          paletteType: PaletteType.hueWheel,
          enableAlpha: false,
          displayThumbColor: true,
          portraitOnly: true,
          colorPickerWidth: 200, // keep wheel compact
          pickerAreaHeightPercent:
              0.75, // slightly reduce internal vertical allocation
          labelTypes: const [],
        ),
      ),
      actions: [
        FilledButton(
            onPressed: () => widget.onDelete(),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete')),
        FilledButton(
          onPressed: () {
            widget.onSubmit(_selectedColor);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
