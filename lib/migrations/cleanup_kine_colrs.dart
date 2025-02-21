import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:weather_blanket/models/weather_data.dart';

class CleanupKineColrs extends StatelessWidget {
  const CleanupKineColrs({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed, child: const Text("Cleanup Kine Colors"));
  }

  onPressed() {
    String kineId = "nz40HrJz7XS8Xb8obKQPzs1KlhA2";
    FirebaseFirestore.instance
        .collection("users")
        .doc(kineId)
        .collection("days")
        .get()
        .then((collection) {
      var counter = 0;
      for (var doc in collection.docs) {
        counter++;
        final weatherData = WeatherForecast.fromFirestore(doc);
        if (weatherData.backgroundColor == null && !weatherData.isKnitted) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(kineId)
              .collection("days")
              .doc(doc.id)
              .delete()
              .then(
                (doc) => print("Document deleted"),
                onError: (e) => print("Error updating document $e"),
              );
        }
      }
      print("total: $counter");
    }, onError: (e) => print(e));
  }
}
