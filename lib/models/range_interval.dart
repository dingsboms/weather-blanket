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
    return {"minTemp": minTemp, "maxTemp": maxTemp, "color": color.toARGB32()};
  }

  factory RangeInterval.fromFirestore(Map<String, dynamic> data) {
    final minTemp = data['minTemp'];
    final maxTemp = data['maxTemp'];
    final intColor = data['color'];
    final color = Color(intColor);
    return RangeInterval(minTemp: minTemp, maxTemp: maxTemp, color: color);
  }

  setText() {
    minTemp = int.parse(minTempController.text);
    maxTemp = int.parse(maxTempController.text);
  }

  setInt() {
    minTempController.text = minTemp.toString();
    maxTempController.text = maxTemp.toString();
  }

  @override
  String toString() {
    return "minTemp: $minTemp, maxTemp: $maxTemp, color: ${color.toARGB32()}";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RangeInterval &&
        other.minTemp == minTemp &&
        other.maxTemp == maxTemp;
  }

  @override
  int get hashCode => Object.hash(minTemp, maxTemp);
}
