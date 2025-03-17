import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/functions/populate_dates.dart';
import 'package:weather_blanket/models/weather_data.dart';

void showPopulationDialog(List<WeatherForecast> items, String userId,
    DateTime startOf2025, BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              content: FutureBuilder<int>(
                future: items.isEmpty
                    ? populateFirestoreFrom(startOf2025, userId)
                    : populateFirestoreFrom(
                        items[0].localDate.add(const Duration(days: 1)),
                        userId),
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
                    print(snapshot.error);
                    return Column(
                      children: [
                        Text('Error: ${snapshot.error}'),
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
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
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          const Text("No new days to populate"),
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context),
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
  });
}
