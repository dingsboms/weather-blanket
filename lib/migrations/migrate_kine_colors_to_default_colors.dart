import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/models/range_interval.dart';
import 'package:weather_blanket/temp_kine_color_values.dart';

class MigrateKineColorsToDefaultColorsButton extends StatelessWidget {
  const MigrateKineColorsToDefaultColorsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: const Text("Migrate colors"),
      onPressed: () => migrateKineColors(),
    );
  }
}

migrateKineColors() {
  final data = getDefualtFirestoreColors();
  FirebaseFirestore.instance.collection("default_colors").add({"colors": data});
}

List<RangeInterval> getDefaultColors() {
  final intervals = List<RangeInterval>.from(kineTemperatureIntervals);
  intervals.sort((a, b) => a.minTemp.compareTo(b.minTemp));
  return intervals;
}

getDefualtFirestoreColors() {
  final intervals = getDefaultColors();
  final data = intervals.map((interval) => interval.toFiretore()).toList();
  return data;
}
