import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather_blanket/color_row.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Weather Blanket',
      theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray),
      home: const MyHomePage(title: 'Weather Blanket'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int numColors = 2;

  Stream<QuerySnapshot> stream =
      FirebaseFirestore.instance.collection("days").snapshots();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        middle: Text(widget.title),
      ),
      child: Column(
        children: [
          const ColorRow(
            colors: [
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.orange,
              Colors.red,
            ],
            height: 30,
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

                          return CupertinoListTile(
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
                          );
                        },
                        childCount: snapshot.data!.docs.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
