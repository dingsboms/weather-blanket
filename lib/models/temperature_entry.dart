import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/temp_kine_color_values.dart';

class TemperatureEntry {
  static final _container = ProviderContainer();

  final DateTime localDate;
  final int temperature;
  final Color backgroundColor;
  final bool isNewMonth;
  final bool isKnitted;
  final String knittingNote;
  final String docId;

  TemperatureEntry({
    required this.localDate,
    required this.temperature,
    required this.backgroundColor,
    required this.isNewMonth,
    required this.isKnitted,
    required this.knittingNote,
    required this.docId,
  });

  factory TemperatureEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final firstEntry = data['data']['properties']['timeseries'][0];

    // Parse date
    final date = firstEntry['time'];
    final parsedDate = DateTime.parse(date);
    final localDate = parsedDate.toLocal();

    // Get temperature
    final temperature =
        firstEntry['data']['instant']['details']['air_temperature'].toInt();

    // Get background color
    final backgroundColor = kineTemperatureIntervals.isEmpty
        ? CupertinoColors.transparent
        : _container.read(colorForTemperatureProvider(temperature));

    // Get additional properties
    final isKnitted = data['is_knitted'] ?? false;
    final knittingNote = data['knitting_note'] ?? "";

    return TemperatureEntry(
      localDate: localDate,
      temperature: temperature,
      backgroundColor: backgroundColor,
      isNewMonth: localDate.day == 1,
      isKnitted: isKnitted,
      knittingNote: knittingNote,
      docId: doc.id,
    );
  }

  static void dispose() {
    _container.dispose();
  }
}
