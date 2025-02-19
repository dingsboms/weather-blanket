import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/toggle_home_page_button.dart';
import 'package:weather_blanket/functions/date_time_to_unix_time.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/functions/populate_dates.dart';
import 'package:weather_blanket/main.dart';
import 'package:weather_blanket/models/weather_data.dart';
import 'package:weather_blanket/settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title, required this.auth});
  final String title;
  final FirebaseAuth auth;

  @override
  ConsumerState<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<HomePage> {
  bool editMode = false;
  bool _dialogShown = false;
  late ProviderContainer container;

  @override
  void initState() {
    super.initState();
    container = ProviderContainer();
  }

  void _showPopulationDialog(
      List<WeatherForecast> items, String userId, DateTime startOf2025) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                content: FutureBuilder<int>(
                  // Change return type to int
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

  User? user = auth.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return ErrorWidget(const Text("User is null"));
    }
    String userId = user!.uid;

    final startOf2025 = DateTime(2025, 1, 1);

    final startOf2025unixSeconds = dateTimeToUnixTimeSeconds(startOf2025);

    final Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("days")
        .where("dt", isGreaterThan: startOf2025unixSeconds)
        .orderBy("dt", descending: true)
        .snapshots();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGrey6,
        leading: ToggleHomePageButton(
          editMode: editMode,
          onToggle: () => setState(() {
            editMode = !editMode;
          }),
        ),
        middle: Text(widget.title),
        trailing: IconButton(
            onPressed: () => {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => SettingsPage(auth: auth)))
                },
            icon: const Icon(Icons.settings)),
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
                  final now = DateTime.now();
                  final daysSinceJanuaryFirst =
                      now.difference(startOf2025).inDays;
                  final items = snapshot.data!.docs
                      .map((doc) => WeatherForecast.fromFirestore(doc))
                      .toList();

                  return FutureBuilder<void>(
                    future: () async {
                      if (!_dialogShown &&
                          daysSinceJanuaryFirst >= items.length) {
                        _dialogShown = true; // Prevent subsequent shows
                        _showPopulationDialog(items, userId, startOf2025);
                      }
                    }(),
                    builder: (context, futureSnapshot) {
                      return Builder(builder: (context) {
                        return editMode
                            ? LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  // Count how many month breaks we have
                                  final numberOfMonthBreaks = items
                                      .where((item) => item.isNewMonth)
                                      .length;

                                  // Calculate height considering both items and month breaks
                                  final double itemHeight =
                                      constraints.maxHeight /
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
                                                      color: ref.watch(
                                                          colorForTemperatureProvider(
                                                              item.temp)),
                                                    ),
                                                    Container(
                                                      height: itemHeight *
                                                          0.01, // Thin separator
                                                      color: CupertinoColors
                                                          .white
                                                          .withOpacity(
                                                              0.3), // Semi-transparent white
                                                    ),
                                                  ],
                                                ),
                                                if (item.isNewMonth)
                                                  Divider(
                                                    color:
                                                        CupertinoColors.white,
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
                                                color: ref.watch(
                                                    colorForTemperatureProvider(
                                                        item.temp)),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: CupertinoColors
                                                        .separator
                                                        .resolveFrom(context),
                                                  ),
                                                ),
                                              ),
                                              child: CupertinoListTile(
                                                leadingSize: 90,
                                                title: Text(
                                                  '${item.temp.round()} °C',
                                                ),
                                                leading: Text(
                                                  '${item.localDate.day}/${item.localDate.month}-${item.localDate.year}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                subtitle: Text(
                                                  '${item.localDate.hour.toString().padLeft(2, "0")}:${item.localDate.minute.toString().padLeft(2, "0")}',
                                                ),
                                                additionalInfo: IconButton(
                                                  onPressed: () {
                                                    showCupertinoModalPopup<
                                                        void>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        // Text editing controllers to manage input
                                                        final TextEditingController
                                                            noteController =
                                                            TextEditingController();

                                                        noteController.text =
                                                            item.knittingNote;

                                                        return Padding(
                                                          padding: EdgeInsets.only(
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom),
                                                          child: Container(
                                                            height:
                                                                400, // Increased height to accommodate form
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: CupertinoColors
                                                                  .systemBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        12),
                                                                topRight: Radius
                                                                    .circular(
                                                                        12),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <Widget>[
                                                                const Text(
                                                                  'Write a note',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
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
                                                                          .all(
                                                                          12),
                                                                  minLines:
                                                                      5, // This will make it 5 lines tall minimum
                                                                  maxLines:
                                                                      10, // This allows it to grow up to 10 lines
                                                                  style:
                                                                      const TextStyle(
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
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                    ),
                                                                    CupertinoButton
                                                                        .filled(
                                                                      child: const Text(
                                                                          'Submit'),
                                                                      onPressed:
                                                                          () {
                                                                        FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                                "users")
                                                                            .doc(
                                                                                userId)
                                                                            .collection(
                                                                                "days")
                                                                            .doc(item
                                                                                .docId)
                                                                            .set({
                                                                          "knitting_note":
                                                                              noteController.text
                                                                        }, SetOptions(merge: true));

                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  icon: item.knittingNote == ""
                                                      ? const Icon(
                                                          Icons.note_add)
                                                      : const Icon(Icons.note),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStateProperty.all<
                                                                Color>(
                                                            CupertinoColors
                                                                .white),
                                                    foregroundColor:
                                                        WidgetStateProperty.all<
                                                                Color>(
                                                            CupertinoColors
                                                                .activeBlue),
                                                    padding: WidgetStateProperty
                                                        .all<EdgeInsets>(
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 8),
                                                    ),
                                                  ),
                                                ),
                                                trailing: CupertinoCheckbox(
                                                  inactiveColor:
                                                      CupertinoColors.white,
                                                  value: item.isKnitted,
                                                  onChanged: (val) => {
                                                    setState(() {
                                                      FirebaseFirestore.instance
                                                          .collection("users")
                                                          .doc(userId)
                                                          .collection("days")
                                                          .doc(item.docId)
                                                          .set(
                                                              {
                                                            "is_knitted": val
                                                          },
                                                              SetOptions(
                                                                  merge: true));
                                                    })
                                                  },
                                                ),
                                              ),
                                            ),
                                            if (item.isNewMonth)
                                              const Divider(
                                                height: 10,
                                                thickness: 10,
                                                color: CupertinoColors.white,
                                              ),
                                          ],
                                        );
                                      },
                                      childCount: items.length,
                                    ),
                                  ),
                                ],
                              );
                      });
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
