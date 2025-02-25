import 'package:flutter/services.dart';

class CoordinateInputFormatter extends TextInputFormatter {
  final bool isLatitude;

  CoordinateInputFormatter({this.isLatitude = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, allow it
    if (newValue.text.isEmpty || newValue.text == '-') {
      return newValue;
    }

    // Initial regex check for basic format
    final regEx = RegExp(r'^[-+]?[0-9]*[.,]?[0-9]*$');
    if (!regEx.hasMatch(newValue.text)) {
      return oldValue;
    }

    // Convert comma to period
    String normalizedText = newValue.text.replaceAll(',', '.');

    // Try parsing the number
    final double? value = double.tryParse(normalizedText);

    // Check if input matches regex and is within valid coordinate range
    bool isValid = value == null || // Allow incomplete numbers
        (isLatitude
            ? (value >= -90 && value <= 90) // Latitude range
            : (value >= -180 && value <= 180)); // Longitude range

    if (isValid) {
      return TextEditingValue(
        text: normalizedText,
        selection: newValue.selection,
        composing: TextRange.empty,
      );
    }

    return oldValue;
  }
}
