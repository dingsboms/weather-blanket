import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/components/generic/small_text_field.dart';
import 'package:weather_blanket/components/location/coordinate_formatter.dart';

class LocationTextField extends StatelessWidget {
  const LocationTextField(
      {super.key, required this.controller, this.isLatitude});
  final TextEditingController controller;
  final bool? isLatitude;

  @override
  Widget build(BuildContext context) {
    return SmallTextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      formatters: [CoordinateInputFormatter(isLatitude: isLatitude ?? false)],
    );
  }
}
