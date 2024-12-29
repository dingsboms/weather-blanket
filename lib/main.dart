import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weather_blanket/home_page.dart';
import 'firebase_options.dart';

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
