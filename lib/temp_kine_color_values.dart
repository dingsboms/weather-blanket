import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/models/range_interval.dart';

final List<RangeInterval> kineTemperatureIntervals = [
  RangeInterval(
      minTemp: -50, maxTemp: -20, color: const Color.fromRGBO(213, 77, 141, 1)),
  RangeInterval(
      minTemp: -19,
      maxTemp: -16,
      color: const Color.fromARGB(255, 224, 83, 219)),
  RangeInterval(
      minTemp: -15,
      maxTemp: -12,
      color: const Color.fromARGB(255, 149, 17, 169)),
  RangeInterval(
      minTemp: -11, maxTemp: -8, color: const Color.fromARGB(255, 12, 18, 103)),
  RangeInterval(
      minTemp: -7, maxTemp: -4, color: const Color.fromARGB(255, 5, 87, 238)),
  RangeInterval(
      minTemp: -3, maxTemp: 0, color: const Color.fromARGB(255, 77, 161, 245)),
  RangeInterval(
      minTemp: 1, maxTemp: 4, color: const Color.fromARGB(255, 118, 184, 156)),
  RangeInterval(
      minTemp: 5, maxTemp: 8, color: const Color.fromARGB(255, 51, 146, 93)),
  RangeInterval(
      minTemp: 9, maxTemp: 12, color: const Color.fromARGB(255, 36, 71, 43)),
  RangeInterval(
      minTemp: 13, maxTemp: 16, color: const Color.fromARGB(255, 230, 211, 4)),
  RangeInterval(
      minTemp: 17, maxTemp: 20, color: const Color.fromARGB(255, 241, 107, 6)),
  RangeInterval(
      minTemp: 21, maxTemp: 24, color: const Color.fromARGB(255, 195, 91, 67)),
  RangeInterval(
      minTemp: 25, maxTemp: 28, color: const Color.fromARGB(255, 232, 57, 77)),
  RangeInterval(
      minTemp: 29, maxTemp: 45, color: const Color.fromARGB(255, 51, 5, 5))
];
