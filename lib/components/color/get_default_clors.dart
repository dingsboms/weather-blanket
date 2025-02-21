import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather_blanket/models/range_interval.dart';

Future<List<RangeInterval>> getDefaultColors() async {
  await FirebaseFirestore.instance
      .collection("default_colors")
      .doc("bjS853oVmBtaa0NHwDqL")
      .get()
      .then((doc) {
    final List<dynamic> colorsData = doc.get('colors') as List<dynamic>;
    final List<RangeInterval> intervals = colorsData
        .map(
            (data) => RangeInterval.fromFirestore(data as Map<String, dynamic>))
        .toList();

    return intervals;
  }, onError: (e) => print("Failed to get default colors: $e"));

  return [];
}
