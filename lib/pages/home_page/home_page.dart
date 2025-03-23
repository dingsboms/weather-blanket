import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/toggle/toggle_home_page_button.dart';
import 'package:weather_blanket/components/weather_components/weather_grid_view.dart';
import 'package:weather_blanket/components/weather_components/weather_list_view.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/models/weather_data.dart';
import 'package:weather_blanket/pages/home_page/show_population_dialog.dart';
import 'package:weather_blanket/pages/settings_page.dart';

// Main HomePage widget
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

// State class
class _HomePageState extends ConsumerState<HomePage> {
  bool editMode = false;
  bool _dialogShown = false;
  late ProviderContainer container;

  @override
  void initState() {
    super.initState();
    _initializeColorRanges();
    container = ProviderContainer();
  }

  void _initializeColorRanges() {
    ref.read(colorRangesProvider.future).then((colorRanges) {
      print('Color ranges loaded: ${colorRanges.length} ranges');
    }).catchError((error) {
      print('Error loading color ranges: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return ErrorWidget(const Text("User is null"));
    }

    return CupertinoPageScaffold(
      navigationBar: _buildNavigationBar(),
      child: SafeArea(
        child: WeatherDataDisplay(
          userId: user.uid,
          editMode: editMode,
          onPopulateDialog: showPopulationDialog,
          dialogShown: _dialogShown,
          onDialogShownChanged: (value) => setState(() => _dialogShown = value),
        ),
      ),
    );
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CupertinoColors.systemGrey6,
      leading: ToggleHomePageButton(
        editMode: editMode,
        onToggle: () => setState(() => editMode = !editMode),
      ),
      middle: Text(widget.title),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => SettingsPage()),
        ),
        icon: const Icon(Icons.settings),
      ),
    );
  }
}

// Weather Data Display Widget
class WeatherDataDisplay extends ConsumerWidget {
  final String userId;
  final bool editMode;
  final Function(List<WeatherForecast>, String, DateTime, BuildContext context)
      onPopulateDialog;
  final bool dialogShown;
  final Function(bool) onDialogShownChanged;

  const WeatherDataDisplay({
    super.key,
    required this.userId,
    required this.editMode,
    required this.onPopulateDialog,
    required this.dialogShown,
    required this.onDialogShownChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = _getWeatherStream();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) =>
          _buildWeatherContent(context, ref, snapshot),
    );
  }

  Stream<QuerySnapshot> _getWeatherStream() {
    final startOf2025 = DateTime(2025, 1, 1);

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("days")
        .where("dt", isGreaterThan: startOf2025)
        .orderBy("dt", descending: true)
        .snapshots();
  }

  Widget _buildWeatherContent(BuildContext context, WidgetRef ref,
      AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final items = snapshot.data!.docs
        .map((doc) => WeatherForecast.fromFirestore(doc))
        .toList();
    final now = DateTime.now();
    final daysSinceJanuaryFirst = now.difference(DateTime(2025, 1, 1)).inDays;

    return FutureBuilder<void>(
      future: _checkAndPopulateData(items, daysSinceJanuaryFirst, context),
      builder: (context, futureSnapshot) {
        return editMode
            ? WeatherGridView(items: items, ref: ref)
            : WeatherListView(userId: userId, items: items, ref: ref);
      },
    );
  }

  Future<void> _checkAndPopulateData(List<WeatherForecast> items,
      int daysSinceJanuaryFirst, BuildContext context) async {
    if (!dialogShown && daysSinceJanuaryFirst >= items.length) {
      onDialogShownChanged(true);
      onPopulateDialog(items, userId, DateTime(2025, 1, 1), context);
    }
  }
}
