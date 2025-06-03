import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/pages/home_page/home_page.dart';
import 'package:weather_blanket/pages/weather_blanket_sign_in_screen.dart';
import 'package:weather_blanket/theme/app_theme.dart';
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
      theme: AppTheme.main,
      home: StreamBuilder<User?>(
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // Handle authentication errors silently in production
              // Consider logging to a proper logging service
            }
            if (!snapshot.hasData) {
              return const WeatherBlanketSignInScreen();
            }
            return const HomePage(
              title: 'Weather Blanket',
            );
            // TODO : Implement a proper profile screen
            return ProfileScreen(
              auth: auth,
              actions: [
                SignedOutAction((context) => Navigator.of(context).pop())
              ],
            );
          }),
    );
  }
}

setPersistanceToLocal() async {
  try {
    await auth.setPersistence(Persistence.LOCAL);
    // Persistence set successfully
  } catch (e) {
    // Handle persistence error silently in production
    // Consider logging to a proper logging service
  }
}
