import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/components/text_field/small_text_field.dart';

class TemperaturePicker extends StatelessWidget {
  const TemperaturePicker(
      {super.key, required this.fromController, required this.toController});
  final TextEditingController fromController;
  final TextEditingController toController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            const Text("From Temperature"),
            SmallTextField(
              controller: fromController,
              keyboardType: const TextInputType.numberWithOptions(),
              formatters: [],
            ),
          ],
        ),
        Column(
          children: [
            const Text("To Temperature"),
            SmallTextField(
              controller: toController,
              keyboardType: const TextInputType.numberWithOptions(),
              formatters: [],
            ),
          ],
        )
      ],
    );
  }
}
