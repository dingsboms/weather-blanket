import 'package:flutter/cupertino.dart';

class RangeInterval {
  int minTemp;
  int maxTemp;
  Color color;
  final TextEditingController minTempController = TextEditingController();
  final TextEditingController maxTempController = TextEditingController();

  RangeInterval({
    required this.minTemp,
    required this.maxTemp,
    required this.color,
  }) {
    minTempController.text = minTemp.toString();
    maxTempController.text = maxTemp.toString();
  }

  toFiretore() {
    return {"minTemp": minTemp, "maxTemp": maxTemp, "color": color.value};
  }

  factory RangeInterval.fromFirestore(Map<String, dynamic> data) {
    final minTemp = data['minTemp'];
    final maxTemp = data['maxTemp'];
    final intColor = data['color'];
    final color = Color(intColor);
    return RangeInterval(minTemp: minTemp, maxTemp: maxTemp, color: color);
  }
}
