import 'package:weather_blanket/models/range_interval.dart';

bool intervalsOverlap(List<RangeInterval> ranges) {
  if (ranges.isEmpty || ranges.length == 1) {
    return false;
  }
  for (var i = 0; i < ranges.length - 1; i++) {
    RangeInterval currentInteval = ranges[i];
    RangeInterval nextInterval = ranges[i + 1];
    if (currentInteval.maxTemp >= nextInterval.minTemp) {
      return true;
    }
  }
  return false;
}
