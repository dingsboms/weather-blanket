import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/toggle/toggle_home_page_button.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/pages/home_page/show_population_dialog.dart';
import 'package:weather_blanket/pages/home_page/weather_data_display.dart';
import 'package:weather_blanket/pages/settings_page.dart';
import 'package:weather_blanket/theme/gradient_background.dart';

// StateProvider to track if the population dialog has been shown this session
final populationDialogShownProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool editMode = false;

  @override
  void initState() {
    super.initState();
    _initializeColorRanges();
  }

  void _initializeColorRanges() {
    ref.read(colorRangesProvider.future).then((colorRanges) {
      // Color ranges loaded successfully
    }).catchError((error) {
      // Handle color ranges loading error silently in production
      // Consider logging to a proper logging service
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return ErrorWidget(const Text("User is null"));
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
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
      leading: ToggleHomePageButton(
        editMode: editMode,
        onToggle: () {
          setState(() {
            editMode = !editMode;
          });
        },
      ),
      middle: Text(widget.title),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const SettingsPage()),
        ),
        icon: const Icon(Icons.settings),
      ),
    );
  }
}
