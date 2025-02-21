import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/models/weather_data.dart';

class MigrateDtFromIntToDatetime extends StatefulWidget {
  const MigrateDtFromIntToDatetime({super.key});

  @override
  State<MigrateDtFromIntToDatetime> createState() =>
      _MigrateDtFromIntToDatetimeState();
}

class _MigrateDtFromIntToDatetimeState
    extends State<MigrateDtFromIntToDatetime> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: const Text("Migrate datetimes"),
    );
  }

  onPressed() async {
    final allUsers = await FirebaseFirestore.instance.collection("users").get();

    for (var user in allUsers.docs) {
      final userId = user.id;

      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("days")
          .get()
          .then((collection) {
        for (var doc in collection.docs) {
          final weatherData = WeatherForecast.fromFirestore(doc);

          FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection("days")
              .doc(doc.id)
              .set(weatherData.toFirestore(), SetOptions(merge: true));
        }
      });
    }
  }
}
