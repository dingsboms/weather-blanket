// isGap, sizeGap, fromInterval, toInterval
import 'package:tempestry/models/range_interval.dart';

(bool, int, RangeInterval?, RangeInterval?) gapInIntervals(
    List<RangeInterval> ranges) {
  if (ranges.isEmpty || ranges.length == 1) {
    return (false, 0, null, null);
  }
  for (var i = 0; i < ranges.length - 1; i++) {
    RangeInterval currentInteval = ranges[i];
    RangeInterval nextInterval = ranges[i + 1];
    int gap = nextInterval.minTemp - currentInteval.maxTemp;
    if (gap > 1) {
      return (true, gap - 1, currentInteval, nextInterval);
    }
  }
  return (false, 0, null, null);
}
