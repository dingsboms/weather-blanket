import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/login_images.dart';
import 'package:weather_blanket/pages/home_page/home_page.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([
    GoogleProvider(
        clientId:
            "88468625362-tat400641fh3pnep52la34ar76kq9u0k.apps.googleusercontent.com"),
    EmailAuthProvider()
  ]);
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
            if (snapshot.hasError) {
              print("snapshot-error: ${snapshot.error}");
            }
            if (!snapshot.hasData) {
              return SignInScreen(
                headerBuilder: (context, constraints, shrinkOffset) =>
                    const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Create a Weather-Blanket!",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 32, color: CupertinoColors.white),
                  ),
                ),
                footerBuilder: (context, action) => const LoginImages(),
              );
            }
            return const HomePage(
              title: 'Weather Blanket',
            );
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
