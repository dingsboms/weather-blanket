import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/test/TestOpenWeatherAPIButton.dart';
import 'package:weather_blanket/home_page.dart';
import 'package:weather_blanket/http_endpoints/test_endpoint.dart';
import 'package:weather_blanket/login_page.dart';
import 'package:weather_blanket/migrations/migrate_days_to_user_kine.dart';
import 'firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

  runApp(ProviderScope(
    child: WeatherBlanketApp(
      auth: auth,
    ),
  ));
}

class WeatherBlanketApp extends StatelessWidget {
  const WeatherBlanketApp({
    super.key,
    required this.auth,
  });
  final FirebaseAuth auth;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Weather Blanket',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
        scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
      ),
      // home: TestOpenWeatherAPIButton(),
      // // home: MigrateDaysToUserKine(),
      // home: CupertinoButton(
      //     child: Text("Call Endpoint"), onPressed: () => callMyFunction()),
      home: StreamBuilder<User?>(
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HomePage(
                title: 'Weather Blanket',
                auth: auth,
              );
            }
            return LoginPage(
              auth: auth,
            );
          }),
    );
  }
}
