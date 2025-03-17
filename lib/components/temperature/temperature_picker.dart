import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/components/location_and_coordinates/location/location_text_field.dart';

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
            LocationTextField(controller: fromController)
          ],
        ),
        Column(
          children: [
            const Text("To Temperature"),
            LocationTextField(
              controller: toController,
            )
          ],
        )
      ],
    );
  }
}
