import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/pages/home_page/home_page.dart';
import 'package:weather_blanket/pages/login_page.dart';
import 'firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

  await setPersistanceToLocal();

  runApp(const ProviderScope(
    child: WeatherBlanketApp(),
  ));
}

class WeatherBlanketApp extends StatelessWidget {
  const WeatherBlanketApp({
    super.key,
  });

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
      home: StreamBuilder<User?>(
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HomePage(
                title: 'Weather Blanket',
              );
            }
            return LoginPage();
          }),
    );
  }
}

setPersistanceToLocal() async {
  try {
    await auth.setPersistence(Persistence.LOCAL);
    print('Persistence set to LOCAL');
  } catch (e) {
    print('Persistence error: $e');
  }
}
