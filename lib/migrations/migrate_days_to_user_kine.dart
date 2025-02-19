import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/models/temperature_entry.dart';
import 'package:weather_blanket/models/weather_data.dart';

class MigrateDaysToUserKine extends StatelessWidget {
  const MigrateDaysToUserKine({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () => migrateToUsers(),
      child: const Text("Migrate to users"),
    );
  }
}

Future<void> migrateToUsers() async {
  try {
    final sourceCollection = FirebaseFirestore.instance.collection("days");
    final destinationCollection = FirebaseFirestore.instance
        .collection("users")
        .doc("nz40HrJz7XS8Xb8obKQPzs1KlhA2")
        .collection("days");

    final QuerySnapshot snapshot = await sourceCollection.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    int operationCount = 0;

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      try {
        // Convert the old document to TemperatureEntry
        final temperatureEntry = TemperatureEntry.fromDoc(doc);

        // Convert to WeatherForecast and get the JSON
        final weatherForecast =
            WeatherForecast.fromTemperatureEntry(temperatureEntry);
        final newData = weatherForecast.toFirestore();

        // Create a new document reference with the same ID
        final destDoc = destinationCollection.doc(doc.id);

        // Add set operation to batch
        batch.set(destDoc, newData);
        operationCount++;

        if (operationCount >= 500) {
          await batch.commit();
          print("Committed batch of 500 documents");
          batch = FirebaseFirestore.instance.batch();
          operationCount = 0;
        }
      } catch (docError) {
        print("Error processing document ${doc.id}: $docError");
        continue;
      }
    }

    if (operationCount > 0) {
      await batch.commit();
      print("Committed final batch of $operationCount documents");
    }

    print("Migration completed successfully!");
  } catch (e) {
    print("Error during migration: $e");
    throw e;
  }
}
