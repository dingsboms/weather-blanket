import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_blanket/pages/home_page/home_page.dart';
import 'package:weather_blanket/pages/settings_page.dart';
import 'package:weather_blanket/pages/weather_blanket_sign_in_screen.dart';
import 'package:weather_blanket/theme/app_theme.dart';
import 'url_strategy_non_web.dart'
    if (dart.library.html) 'url_strategy_web.dart';
import 'firebase_options.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;
late final GoRouter _router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  auth = FirebaseAuth.instanceFor(app: app);

  configureUrlStrategy();

  // Makes sure that the URL's are updated in the browser when navigating
  // with context.push
  GoRouter.optionURLReflectsImperativeAPIs = true;

  _router = GoRouter(
    routes: [
      GoRoute(
          path: "/",
          builder: (context, state) {
            return const HomePage();
          },
          routes: [
            GoRoute(
              path: "login",
              builder: (context, state) => const WeatherBlanketSignInScreen(),
            ),
            GoRoute(
                path: "settings",
                builder: (context, state) {
                  return const SettingsPage();
                }),
          ])
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;

      if (state.fullPath == "/privacy-policy" ||
          state.fullPath == "/terms-of-service" ||
          state.fullPath == "/landing-page" ||
          state.fullPath == "/support") {
        return null;
      }

      if (!isLoggedIn && state.fullPath != '/login') {
        return '/login';
      } else if (isLoggedIn && state.fullPath == '/login') {
        return '/';
      }
      return null;
    },
  );

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
    return CupertinoApp.router(
      routerConfig: _router,
      title: 'Weather Blanket',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.main,
    );
  }
}
