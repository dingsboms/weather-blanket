import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/components/text_field/small_text_field.dart';
import 'package:weather_blanket/components/location_and_coordinates/location/coordinate_formatter.dart';

class LocationTextField extends StatelessWidget {
  const LocationTextField(
      {super.key, required this.controller, this.isLatitude});
  final TextEditingController controller;
  final bool? isLatitude;

  @override
  Widget build(BuildContext context) {
    return SmallTextField(
      controller: controller,
      formatters: [CoordinateInputFormatter(isLatitude: isLatitude ?? false)],
    );
  }
}
