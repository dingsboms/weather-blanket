import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/location_and_coordinates/location_and_autocomplete.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/models/weather_data.dart';

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

  @override
  void initState() {
    forecast = widget.item;
    super.initState();
  }

  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
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
                      if (mounted) {
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
                          String userId =
                              FirebaseAuth.instance.currentUser!.uid;
                          try {
                            final updatedItem =
                                await WeatherForecast.fromOpenWeatherAPI(
                                    dateTime: chosenDateTime,
                                    docId: forecast.docId);
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(userId)
                                .collection("days")
                                .doc(forecast.docId)
                                .set(updatedItem!.toFirestore(),
                                    SetOptions(merge: true));

                            setState(() {
                              forecast = updatedItem;
                            });
                          } catch (e) {
                            Text("Failed to updated tile: ${e}");
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
          SizedBox(
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                  color: widget.ref
                      .watch(colorForTemperatureProvider(forecast.temp))),
            ),
          ),
        ],
      ),
    );
  }
}
