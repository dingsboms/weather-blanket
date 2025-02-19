int dateTimeToUnixTimeSeconds(DateTime dateTime) {
  return dateTime.millisecondsSinceEpoch ~/ 1000;
}
