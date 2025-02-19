import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:weather_blanket/components/temperature/temperature_picker.dart';
import 'package:weather_blanket/models/range_interval.dart';

class ColorPickerBox extends StatefulWidget {
  const ColorPickerBox(
      {super.key, required this.rangeInterval, required this.onUpdate});
  final RangeInterval rangeInterval;
  final Future<void> Function(Color pickedColor) onUpdate;

  @override
  State<ColorPickerBox> createState() => _ColorPickerBoxState();
}

class _ColorPickerBoxState extends State<ColorPickerBox> {
  late Color pickerColor = widget.rangeInterval.color;
  late Color currentColor = widget.rangeInterval.color;
  late RangeInterval rangeInterval = widget.rangeInterval;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TemperaturePicker(
                      fromController: rangeInterval.minTempController,
                      toController: rangeInterval.maxTempController,
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
                  child: const Text('Update'),
                  onPressed: () async {
                    setState(() {
                      currentColor = pickerColor;
                    });
                    Navigator.of(context).pop();
                    await widget.onUpdate(pickerColor);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: currentColor,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
