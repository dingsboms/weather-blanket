import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_blanket/components/toggle/toggle_home_page_button.dart';
import 'package:weather_blanket/pages/home_page/show_population_dialog.dart';
import 'package:weather_blanket/pages/home_page/weather_data_display.dart';
import 'package:weather_blanket/theme/gradient_background.dart';

// StateProvider to track if the population dialog has been shown this session
final populationDialogShownProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool editMode = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GradientScaffold(
            child: SafeArea(
              child: Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                ),
              ),
            ),
          );
        }

        // User is authenticated, initialize color ranges and show main content
        final user = snapshot.data;
        if (user == null) {
          // This should trigger the auth guard in your router
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const GradientScaffold(
            child: SafeArea(
              child: Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                ),
              ),
            ),
          );
        }

        return GradientScaffold(
          navigationBar: _buildNavigationBar(),
          child: SafeArea(
            child: WeatherDataDisplay(
              userId: user.uid,
              editMode: editMode,
              onPopulateDialog: showPopulationDialog,
            ),
          ),
        );
      },
    );
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CupertinoColors.systemBackground.withOpacity(0),
      enableBackgroundFilterBlur: false,
      leading: ToggleHomePageButton(
        editMode: editMode,
        onToggle: () {
          setState(() {
            editMode = !editMode;
          });
        },
      ),
      middle: const Text("Tempestry"),
      trailing: IconButton(
        onPressed: () => context.push(
          "/settings",
        ),
        icon: const Icon(Icons.settings),
      ),
    );
  }
}
