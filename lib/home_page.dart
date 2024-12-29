import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_blanket/models/range_interval.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool editMode = false;

  final Stream<QuerySnapshot> stream =
      FirebaseFirestore.instance.collection("days").snapshots();

  @override
  void initState() {
    super.initState();
  }

  var temperatureIntervals = [
    RangeInterval(
        minTemp: -50,
        maxTemp: -20,
        color: const Color.fromRGBO(213, 77, 141, 1)),
    RangeInterval(
        minTemp: -19,
        maxTemp: -16,
        color: const Color.fromARGB(255, 224, 83, 219)),
    RangeInterval(
        minTemp: -15,
        maxTemp: -12,
        color: const Color.fromARGB(255, 149, 17, 169)),
    RangeInterval(
        minTemp: -14,
        maxTemp: -8,
        color: const Color.fromARGB(255, 12, 18, 103)),
    RangeInterval(
        minTemp: -7, maxTemp: -4, color: const Color.fromARGB(255, 5, 87, 238)),
    RangeInterval(
        minTemp: -3,
        maxTemp: 0,
        color: const Color.fromARGB(255, 77, 161, 245)),
    RangeInterval(
        minTemp: 1,
        maxTemp: 4,
        color: const Color.fromARGB(255, 118, 184, 156)),
    RangeInterval(
        minTemp: 3, maxTemp: 8, color: const Color.fromARGB(255, 51, 146, 93)),
    RangeInterval(
        minTemp: 9, maxTemp: 12, color: const Color.fromARGB(255, 36, 71, 43)),
    RangeInterval(
        minTemp: 13,
        maxTemp: 16,
        color: const Color.fromARGB(255, 230, 211, 4)),
    RangeInterval(
        minTemp: 17,
        maxTemp: 20,
        color: const Color.fromARGB(255, 241, 107, 6)),
    RangeInterval(
        minTemp: 21,
        maxTemp: 24,
        color: const Color.fromARGB(255, 195, 91, 67)),
    RangeInterval(
        minTemp: 25,
        maxTemp: 28,
        color: const Color.fromARGB(255, 232, 57, 77)),
    RangeInterval(
        minTemp: 29, maxTemp: 45, color: const Color.fromARGB(255, 51, 5, 5))
  ];

  Color getColorForTemperature(double temperature) {
    for (var interval in temperatureIntervals) {
      if (temperature <= interval.maxTemp) {
        return interval.color;
      }
    }
    return temperatureIntervals.isEmpty
        ? Colors.transparent
        : temperatureIntervals.last.color;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGrey6,
        middle: Text(widget.title),
      ),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                return CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var doc = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          var firstEntry =
                              doc['data']['properties']['timeseries'][0];
                          var date = firstEntry['time'];
                          var parsedDate = DateTime.parse(date);
                          var localDate = parsedDate.toLocal();
                          var temperature = firstEntry['data']['instant']
                              ['details']['air_temperature'];

                          Color backgroundColor = temperatureIntervals.isEmpty
                              ? Colors.transparent
                              : getColorForTemperature(temperature.toDouble());

                          return Container(
                            decoration: BoxDecoration(
                              color: backgroundColor.withOpacity(0.3),
                              border: Border(
                                bottom: BorderSide(
                                  color: CupertinoColors.separator
                                      .resolveFrom(context),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: CupertinoListTile(
                              title: Text(
                                '${localDate.day}/${localDate.month}-${localDate.year}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                '${localDate.hour.toString().padLeft(2, "0")}:${localDate.minute.toString().padLeft(2, "0")}',
                              ),
                              trailing: Text(
                                '$temperature°C',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                        },
                        childCount: snapshot.data!.docs.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
