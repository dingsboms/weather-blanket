import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tempestry/pages/configure_new_user_page.dart';
import 'package:tempestry/pages/home_page/home_page.dart';
import 'package:tempestry/pages/settings_page.dart';
import 'package:tempestry/pages/weather_blanket_sign_in_screen.dart';
import 'package:tempestry/theme/app_theme.dart';
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
              builder: (context, state) => const TempestrySignInScreen(),
            ),
            GoRoute(
                path: "settings",
                builder: (context, state) {
                  return const SettingsPage();
                }),
            GoRoute(
              path: "configure_new_user",
              builder: (context, state) => const ConfigureNewUserPage(),
            )
          ])
    ],
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;

      if (state.fullPath == "/privacy-policy" ||
          state.fullPath == "/terms-of-service" ||
          state.fullPath == "/landing-page" ||
          state.fullPath == "/support") {
        return null;
      }

      if (state.fullPath != '/login' && !isLoggedIn) {
        // If the user is not logged in and trying to access a page other than login, redirect to login
        return '/login';
      }

      return null;
    },
  );

  runApp(const ProviderScope(
    child: TempestryApp(),
  ));
}

class TempestryApp extends StatelessWidget {
  const TempestryApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      routerConfig: _router,
      title: 'Tempestry',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.main,
    );
  }
}
