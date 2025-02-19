import 'package:flutter/services.dart';

class CoordinateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final regEx = RegExp(r'^[-+]?[0-9]*\.?[0-9]*$');
    final double? newNumber = double.tryParse(newValue.text);

    // If the new value is empty, allow it (for backspace functionality)
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Check if the input matches regex or is a valid coordinate within range
    if (regEx.hasMatch(newValue.text) &&
        (newNumber == null ||
            (newNumber >= -180 && newNumber <= 180) || // For longitude
            (newNumber >= -90 && newNumber <= 90))) {
      // For latitude
      return newValue;
    }

    // If not, revert to the old value
    return oldValue;
  }
}
