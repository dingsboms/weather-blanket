import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather_blanket/models/weather_data.dart';

Future<int> populateFirestoreFrom(DateTime fromDate, String userId) async {
  final today = DateTime.now();
  var dateCounter = fromDate;
  dateCounter =
      DateTime(dateCounter.year, dateCounter.month, dateCounter.day, 12, 0, 0);
  final difference = today.difference(fromDate);
  const oneDay = Duration(days: 1);

  var daysPopulated = 0;
  for (var i = 0; i < difference.inDays + 1; i++) {
    if (dateCounter.isAfter(today)) {
      break;
    }
    daysPopulated += 1;

    try {
      String docId = dateCounter.millisecondsSinceEpoch.toString();
      final res = await WeatherForecast.fromOpenWeatherAPI(
          dateTime: dateCounter.toLocal(), docId: docId);

      if (res != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("days")
            .doc(docId)
            .set(res.toFirestore());
      }

      dateCounter = dateCounter.add(oneDay);
    } catch (e) {
      throw Exception('Failed to populate weather data for $dateCounter: $e');
    }
  }
  return daysPopulated;
}
