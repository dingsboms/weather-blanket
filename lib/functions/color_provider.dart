// lib/functions/color_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:tempestry/functions/get_user_doc.dart';
import '../models/range_interval.dart';

final colorRangesProvider = FutureProvider<List<RangeInterval>>((ref) async {
  final doc = await getUserDoc();
  if (!doc.exists) return [];
  if (!doc.data()!.containsKey('colors')) return [];
  final raw = doc.get('colors');
  if (raw is! List) return [];
  final list = raw
      .whereType<Map<String, dynamic>>()
      .map(RangeInterval.fromFirestore)
      .toList();
  list.sort((a, b) => a.minTemp.compareTo(b.minTemp));
  return list;
});

final colorForTemperatureProvider =
    Provider.family<Color, int>((ref, temperature) {
  final colorRangesAsync = ref.watch(colorRangesProvider);

  return colorRangesAsync.when(
    data: (ranges) {
      if (ranges.isNotEmpty && temperature <= ranges.first.minTemp) {
        return ranges.first.color;
      }
      if (ranges.isNotEmpty && temperature >= ranges.last.maxTemp) {
        return ranges.last.color;
      }

      for (var interval in ranges) {
        if (interval.minTemp <= temperature &&
            temperature <= interval.maxTemp) {
          return interval.color;
        }
      }
      return CupertinoColors.transparent;
    },
    loading: () => CupertinoColors.transparent,
    error: (_, __) => CupertinoColors.transparent,
  );
});
