import 'package:tempestry/models/range_interval.dart';

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
