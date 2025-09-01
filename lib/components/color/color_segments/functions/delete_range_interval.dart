import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tempestry/models/range_interval.dart';
import 'package:tempestry/functions/get_user_doc.dart';
import 'package:tempestry/components/color/color_segments/functions/update_colors.dart';

Future<List<RangeInterval>> deleteRangeInterval(
    RangeInterval intervalToDelete, List<RangeInterval> ranges) async {
  final removeIndex = ranges.indexWhere((interval) =>
      interval.minTemp == intervalToDelete.minTemp &&
      interval.maxTemp == intervalToDelete.maxTemp);

  if (removeIndex != -1) {
    final removedInterval = ranges.removeAt(removeIndex);

    // Get surrounding elements
    final elementBefore = removeIndex > 0 ? ranges[removeIndex - 1] : null;
    final elementAfter =
        removeIndex < ranges.length ? ranges[removeIndex] : null;

    final temperatureIntervalToFill =
        removedInterval.maxTemp - removedInterval.minTemp;

    for (var i = 0; i <= temperatureIntervalToFill; i++) {
      bool incrementElementBefore = i % 2 == 0;
      if (incrementElementBefore && elementBefore != null) {
        elementBefore.maxTemp += 1;
      } else if (!incrementElementBefore && elementAfter != null) {
        elementAfter.minTemp -= 1;
      }
    }

    elementBefore?.setInt();
    elementAfter?.setInt();
  }

  return ranges;
}

/// Fetches the current user's color range intervals from Firestore, removes the
/// provided [intervalToDelete] (re-distributing its span across neighboring
/// intervals using [deleteRangeInterval]), then persists the updated list back
/// to Firestore. Returns the updated list that was successfully stored. If the
/// interval isn't found or persistence fails, the original list from Firestore
/// is returned.
Future<List<RangeInterval>> deleteRangeIntervalFromFirestore(
    RangeInterval intervalToDelete, WidgetRef ref) async {
  try {
    final doc = await getUserDoc();
    final raw = doc.data()?['colors'];
    if (raw is! List) return [];
    final ranges = raw
        .whereType<Map<String, dynamic>>()
        .map(RangeInterval.fromFirestore)
        .toList();
    ranges.sort((a, b) => a.minTemp.compareTo(b.minTemp));

    final originalLength = ranges.length;
    final updated = await deleteRangeInterval(intervalToDelete, ranges);

    // If nothing was removed, just return the fetched list.
    if (updated.length == originalLength) {
      return updated;
    }

    final success = await updateColors(updated, ref);
    if (!success) {
      // If update failed (e.g. overlap detection), return original fetched list.
      return ranges;
    }
    return updated;
  } catch (_) {
    // On error, return empty list (callers can decide how to handle).
    return [];
  }
}
