import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tempestry/components/color/color_box.dart';
import 'package:tempestry/components/location_and_coordinates/location_and_autocomplete.dart';
import 'package:tempestry/functions/color_provider.dart';
import 'package:tempestry/models/weather_data.dart';
// import 'package:tempestry/models/range_interval.dart';

class WeatherItemScreen extends StatefulWidget {
  const WeatherItemScreen({
    super.key,
    required this.item,
    required this.ref,
  });
  final WeatherForecast item;
  final WidgetRef ref;

  @override
  State<WeatherItemScreen> createState() => _WeatherItemScreenState();
}

class _WeatherItemScreenState extends State<WeatherItemScreen> {
  late WeatherForecast forecast;
  // int? _pickedTemp;

  @override
  void initState() {
    forecast = widget.item;
    super.initState();
  }

  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final asyncRanges = widget.ref.watch(colorRangesProvider);
    final providerColor =
        widget.ref.watch(colorForTemperatureProvider(forecast.temp));
    // final currentColor = providerColor;
    return CupertinoAlertDialog(
      title: Text(
          "Date: ${forecast.dt.day} / ${forecast.dt.month} - ${forecast.dt.year}"),
      content: Column(
        children: [
          Text("Temperature: ${forecast.temp}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Time: "),
              CupertinoButton(
                  onPressed: () async {
                    final chosenTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(forecast.dt),
                    );
                    if (chosenTime != null) {
                      final chosenDateTime = DateTime(
                          forecast.dt.year,
                          forecast.dt.month,
                          forecast.dt.day,
                          chosenTime.hour,
                          chosenTime.minute);

                      final now = DateTime.now();
                      if (context.mounted) {
                        if (chosenDateTime.isAfter(now)) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  title: Text("Error"),
                                  content: Text(
                                      "Cannot set time after now, \nPlease select a time that has occured"),
                                );
                              });
                        } else {
                          try {
                            final updatedItem =
                                await WeatherForecast.fromOpenWeatherAPI(
                                    dateTime: chosenDateTime,
                                    docId: forecast.docId);
                            if (updatedItem == null) {
                              throw Exception(
                                  "Failed to get updatetItem fromOpenWeatherApi");
                            }
                            await updatedItem.updateFirestoreUserDoc();

                            setState(() {
                              forecast = updatedItem;
                            });
                          } catch (e) {
                            Text("Failed to updated tile: $e");
                          }
                        }
                      }
                    }
                  },
                  child: Text(
                      "${"${forecast.dt.hour}".padLeft(2, "0")} : ${"${forecast.dt.minute}".padLeft(2, "0")}")),
            ],
          ),
          LocationAndAutocomplete(
            weatherItem: widget.item,
          ),
          asyncRanges.when(
            loading: () => const CupertinoActivityIndicator(),
            error: (err, st) => const Text('Failed to load colors'),
            data: (ranges) {
              return SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ranges.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final interval = ranges[idx];
                    return GestureDetector(
                      onTap: () async {
                        // Pick a temp in the interval (use mid-point)
                        final newTemp =
                            ((interval.minTemp + interval.maxTemp) / 2).round();
                        final updated = widget.item.copyWith(temp: newTemp);
                        await updated.updateFirestoreUserDoc();
                        if (mounted) {
                          setState(() {
                            forecast = updated;
                          });
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: interval.color,
                          border: Border.all(
                            color: (providerColor == interval.color)
                                ? Colors.blueAccent
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
