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

  final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
      .collection("days")
      .where("timestamp",
          isGreaterThan: Timestamp.fromDate(DateTime(2024, 12, 31, 23, 59, 59)))
      .orderBy("timestamp", descending: true)
      .snapshots();

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
        trailing: IconButton(
          onPressed: () => setState(() {
            editMode = !editMode;
          }),
          icon: editMode
              ? const Icon(Icons.list_alt_sharp)
              : const Icon(Icons.list),
        ),
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

                // Hoist the data processing
                final items = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final firstEntry =
                      data['data']['properties']['timeseries'][0];
                  final date = firstEntry['time'];
                  final parsedDate = DateTime.parse(date);
                  final localDate = parsedDate.toLocal();
                  final temperature = firstEntry['data']['instant']['details']
                          ['air_temperature']
                      .round();
                  final backgroundColor = temperatureIntervals.isEmpty
                      ? Colors.transparent
                      : getColorForTemperature(temperature.toDouble());

                  final isKnitted = data['is_knitted'] || false;
                  final String knittingNote = data['knitting_note'] ?? "";
                  final docId = doc.id;

                  // Check if it's the first day of a month
                  final isNewMonth = localDate.day == 1;

                  return (
                    localDate: localDate,
                    temperature: temperature,
                    backgroundColor: backgroundColor,
                    isNewMonth: isNewMonth,
                    isKnitted: isKnitted,
                    knittingNote: knittingNote,
                    docId: docId
                  );
                }).toList();

                return editMode
                    ? LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          // Count how many month breaks we have
                          final numberOfMonthBreaks =
                              items.where((item) => item.isNewMonth).length;

                          // Calculate height considering both items and month breaks
                          final double itemHeight = constraints.maxHeight /
                              (items.length + numberOfMonthBreaks);

                          return CustomScrollView(
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final item = items[index];

                                    return Column(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              height: itemHeight *
                                                  0.99, // Slightly reduce height to make room for separator
                                              color: item.backgroundColor,
                                            ),
                                            Container(
                                              height: itemHeight *
                                                  0.01, // Thin separator
                                              color: Colors.white.withOpacity(
                                                  0.3), // Semi-transparent white
                                            ),
                                          ],
                                        ),
                                        if (item.isNewMonth)
                                          Divider(
                                            color: Colors.white,
                                            thickness: itemHeight,
                                            height: itemHeight,
                                          ),
                                      ],
                                    );
                                  },
                                  childCount: items.length,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = items[index];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: item.backgroundColor,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: CupertinoColors.separator
                                                .resolveFrom(context),
                                          ),
                                        ),
                                      ),
                                      child: CupertinoListTile(
                                        leadingSize: 90,
                                        title: Text(
                                          '${item.temperature.round()} °C',
                                        ),
                                        leading: Text(
                                          '${item.localDate.day}/${item.localDate.month}-${item.localDate.year}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        subtitle: Text(
                                          '${item.localDate.hour.toString().padLeft(2, "0")}:${item.localDate.minute.toString().padLeft(2, "0")}',
                                        ),
                                        additionalInfo: IconButton(
                                          onPressed: () {
                                            showCupertinoModalPopup<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // Text editing controllers to manage input
                                                final TextEditingController
                                                    noteController =
                                                    TextEditingController();

                                                noteController.text =
                                                    item.knittingNote;

                                                return Container(
                                                  height:
                                                      400, // Increased height to accommodate form
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: CupertinoColors
                                                        .systemBackground,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(12),
                                                      topRight:
                                                          Radius.circular(12),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      const Text(
                                                        'Write a note',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      CupertinoTextField(
                                                        controller:
                                                            noteController,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        minLines:
                                                            5, // This will make it 5 lines tall minimum
                                                        maxLines:
                                                            10, // This allows it to grow up to 10 lines
                                                        style: const TextStyle(
                                                          color: CupertinoColors
                                                              .black, // This fixes the text color
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: CupertinoColors
                                                                  .systemGrey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          CupertinoButton(
                                                            child: const Text(
                                                                'Cancel'),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          ),
                                                          CupertinoButton
                                                              .filled(
                                                            child: const Text(
                                                                'Submit'),
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "days")
                                                                  .doc(item
                                                                      .docId)
                                                                  .set(
                                                                      {
                                                                    "knitting_note":
                                                                        noteController
                                                                            .text
                                                                  },
                                                                      SetOptions(
                                                                          merge:
                                                                              true));

                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: item.knittingNote == ""
                                              ? Icon(Icons.note_add)
                                              : Icon(Icons.note),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.white),
                                            foregroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.blue),
                                            padding: WidgetStateProperty.all<
                                                EdgeInsets>(
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 8),
                                            ),
                                          ),
                                        ),
                                        trailing: CupertinoCheckbox(
                                          inactiveColor: Colors.white,
                                          value: item.isKnitted,
                                          onChanged: (val) => {
                                            setState(() {
                                              FirebaseFirestore.instance
                                                  .collection("days")
                                                  .doc(item.docId)
                                                  .set({"is_knitted": val},
                                                      SetOptions(merge: true));
                                            })
                                          },
                                        ),
                                      ),
                                    ),
                                    if (item.isNewMonth)
                                      const Divider(
                                        height: 10,
                                        thickness: 10,
                                        color: Colors.white,
                                      ),
                                  ],
                                );
                              },
                              childCount: items.length,
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
