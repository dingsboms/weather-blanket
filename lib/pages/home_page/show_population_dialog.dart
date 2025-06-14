import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:tempestry/functions/populate_dates.dart';
import 'package:tempestry/models/weather_data.dart';

Future<void> showPopulationDialog(List<WeatherForecast> items, String userId,
    DateTime startOf2025, BuildContext context) async {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Check if temperature_location is set for user
    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if (!userDoc.exists || userDoc.data()?['temperature_location'] == null) {
      if (context.mounted) {
        context.go("/configure_new_user");
      }
      return;
    }
    if (context.mounted) {
      await showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                content: FutureBuilder<int>(
                  future: items.isEmpty
                      ? populateFirestoreFrom(startOf2025)
                      : populateFirestoreFrom(
                          items.first.localDate.add(const Duration(days: 1))),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Column(
                        children: [
                          CupertinoActivityIndicator(),
                          SizedBox(height: 10),
                          Text("Populating missing days.."),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      // Handle population error silently in production
                      // Consider logging to a proper logging service
                      return Column(
                        children: [
                          Text('Error: ${snapshot.error}'),
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      );
                    } else {
                      // Check the number of days populated
                      final daysPopulated = snapshot.data ?? 0;
                      if (daysPopulated > 0) {
                        return Column(
                          children: [
                            Text("Populated $daysPopulated new days"),
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => context.pop(),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            const Text("No new days to populate"),
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => context.pop(),
                            ),
                          ],
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      );
    }
  });
}
