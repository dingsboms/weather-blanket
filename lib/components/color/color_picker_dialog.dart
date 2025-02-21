// New reusable ColorPickerDialog widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:weather_blanket/components/temperature/temperature_picker.dart';
import 'package:weather_blanket/models/range_interval.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final RangeInterval rangeInterval;
  final Future<void> Function(Color pickedColor) onUpdate;
  final Future<void> Function() onDelete;
  final bool Function() intervalsOverlap;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.rangeInterval,
    required this.onUpdate,
    required this.onDelete,
    required this.intervalsOverlap,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color pickerColor;

  @override
  void initState() {
    super.initState();
    pickerColor = widget.initialColor;
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TemperaturePicker(
              fromController: widget.rangeInterval.minTempController,
              toController: widget.rangeInterval.maxTempController,
            ),
            ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () =>
              showSureYouWantToDeleteDialog(context, widget.onDelete),
          child: const Text(
            "Delete",
            style: TextStyle(color: CupertinoColors.destructiveRed),
          ),
        ),
        ElevatedButton(
          child: const Text('Update'),
          onPressed: () async {
            widget.rangeInterval.setText();
            bool intervalsOverlap = widget.intervalsOverlap();
            if (intervalsOverlap) {
              showErrorDialog();
            } else {
              Navigator.of(context).pop();
              await widget.onUpdate(pickerColor);
            }
          },
        ),
      ],
    );
  }

  static void showSureYouWantToDeleteDialog(
      BuildContext context, Future<void> Function() onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sure you want to delete?"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                Navigator.pop(context);
                await onDelete();
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
          ],
        );
      },
    );
  }

  showErrorDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Title(
                color: CupertinoColors.activeOrange,
                child: const Text("Error")),
            content: const Text(
                "Interval is overlapping with other intervals, pick a valid range"),
            actions: [
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              )
            ],
          );
        });
  }
}
