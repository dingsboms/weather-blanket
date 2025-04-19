import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/weather_components/weather_grid_view.dart';
import 'package:weather_blanket/components/weather_components/weather_list_view.dart';
import 'package:weather_blanket/models/weather_data.dart';
import 'package:weather_blanket/pages/home_page/home_page.dart';

class WeatherDataDisplay extends ConsumerWidget {
  final String userId;
  final bool editMode;
  final Future<void> Function(
          List<WeatherForecast>, String, DateTime, BuildContext context)
      onPopulateDialog;

  const WeatherDataDisplay({
    super.key,
    required this.userId,
    required this.editMode,
    required this.onPopulateDialog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = _getWeatherStream(userId);
    final dialogShown = ref.watch(populationDialogShownProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) => _buildWeatherContent(context, ref,
          snapshot, dialogShown, userId, editMode, onPopulateDialog),
    );
  }

  Stream<QuerySnapshot> _getWeatherStream(String userId) {
    final startOf2025 = DateTime(2025, 1, 1);
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("days")
        .where("dt", isGreaterThan: startOf2025)
        .orderBy("dt", descending: true)
        .snapshots();
  }

  Widget _buildWeatherContent(
      BuildContext context,
      WidgetRef ref,
      AsyncSnapshot<QuerySnapshot> snapshot,
      bool dialogShown,
      String userId,
      bool editMode,
      Future<void> Function(
              List<WeatherForecast>, String, DateTime, BuildContext context)
          onPopulateDialog) {
    if (!snapshot.hasData) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final items = snapshot.data!.docs
        .map((doc) => WeatherForecast.fromFirestore(doc))
        .toList();
    final now = DateTime.now();
    final daysSinceJanuaryFirst = now.difference(DateTime(2025, 1, 1)).inDays;

    // Check and potentially show the dialog only once per session
    if (!dialogShown && daysSinceJanuaryFirst >= items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(populationDialogShownProvider.notifier).state =
            true; // Mark as shown
        await onPopulateDialog(
            List.from(items), userId, DateTime(2025, 1, 1), context);
      });
    }

    return editMode
        ? WeatherGridView(items: items, ref: ref)
        : WeatherListView(userId: userId, items: items, ref: ref);
  }
}
