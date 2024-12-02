import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather_blanket/linear_gradient_container.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Weather Blanket',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
        scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
      ),
      home: MyHomePage(title: 'Weather Blanket'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class RangeInterval {
  final double minTemp;
  final double maxTemp;
  final Color color;

  RangeInterval({
    required this.minTemp,
    required this.maxTemp,
    required this.color,
  });
}

class _MyHomePageState extends State<MyHomePage> {
  bool editMode = false;
  bool isLoading = true;
  List<RangeInterval> temperatureIntervals = [];
  late List<double> initialPositions;
  final List<double> defaultPositions = [0.05, 0.25, 0.5, 0.75, 0.95];

  final List<Color> gradientColors = const [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Color.fromARGB(255, 121, 1, 1),
  ];

  final Stream<QuerySnapshot> stream =
      FirebaseFirestore.instance.collection("days").snapshots();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Color getColorAtPosition(double position) {
    if (position <= 0) return gradientColors.first;
    if (position >= 1) return gradientColors.last;

    double segmentLength = 1 / (gradientColors.length - 1);
    int index = (position / segmentLength).floor();

    if (index >= gradientColors.length - 1) return gradientColors.last;

    double localPosition = (position - index * segmentLength) / segmentLength;
    return Color.lerp(
      gradientColors[index],
      gradientColors[index + 1],
      localPosition,
    )!;
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('colors')
          .doc('positions')
          .get();

      if (doc.exists &&
          doc.data() != null &&
          doc.data()!['positions'] != null) {
        List<dynamic> positions = doc.data()!['positions'];
        initialPositions =
            positions.map((pos) => (pos as num).toDouble()).toList();
        print('Loaded positions from Firestore: $initialPositions');
      } else {
        initialPositions = List.from(defaultPositions);
        print('Using default positions: $initialPositions');
      }

      _initializeIntervals();
    } catch (e) {
      print('Error loading positions: $e');
      initialPositions = List.from(defaultPositions);
      _initializeIntervals();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeIntervals() {
    List<RangeInterval> intervals = [];
    for (int i = 0; i < initialPositions.length; i++) {
      double temp = -20 + (50 * initialPositions[i]);
      Color color = getColorAtPosition(initialPositions[i]);

      if (i == 0) {
        intervals.add(RangeInterval(
          minTemp: double.negativeInfinity,
          maxTemp: temp,
          color: color,
        ));
      } else {
        intervals.add(RangeInterval(
          minTemp: -20 + (50 * initialPositions[i - 1]),
          maxTemp: temp,
          color: color,
        ));
      }
    }

    if (mounted) {
      setState(() {
        temperatureIntervals = intervals;
      });
    }
  }

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

  Future<void> _updateColorsToFirestore() async {
    try {
      print('Saving positions to Firestore: $initialPositions');
      await FirebaseFirestore.instance
          .collection('colors')
          .doc('positions')
          .set({
        'positions': initialPositions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Positions saved successfully');
    } catch (e) {
      print('Error saving positions: $e');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save positions: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CupertinoPageScaffold(
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGrey6,
        middle: Text(widget.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            editMode
                ? CupertinoIcons.check_mark
                : CupertinoIcons.slider_horizontal_3,
            color: CupertinoColors.activeBlue,
          ),
          onPressed: () {
            setState(() {
              editMode = !editMode;
              if (!editMode) {
                _updateColorsToFirestore();
              }
            });
          },
        ),
      ),
      child: Column(
        children: [
          TemperatureRangeSelector(
            editMode: editMode,
            initialPositions: initialPositions,
            onPositionsChanged: (positions, colors) {
              setState(() {
                initialPositions = positions;
                List<RangeInterval> intervals = [];
                for (int i = 0; i < positions.length; i++) {
                  double temp = -20 + (50 * positions[i]);
                  if (i == 0) {
                    intervals.add(RangeInterval(
                      minTemp: double.negativeInfinity,
                      maxTemp: temp,
                      color: colors[i],
                    ));
                  } else {
                    intervals.add(RangeInterval(
                      minTemp: -20 + (50 * positions[i - 1]),
                      maxTemp: temp,
                      color: colors[i],
                    ));
                  }
                }
                temperatureIntervals = intervals;
              });
            },
          ),
          const SizedBox(height: 20),
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
