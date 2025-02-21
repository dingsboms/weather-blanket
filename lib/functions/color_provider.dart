// lib/functions/color_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/range_interval.dart';

final colorRangesProvider = FutureProvider<List<RangeInterval>>((ref) async {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  if (user == null) {
    throw Exception('User not authenticated');
  }

  final doc =
      await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

  final colorsData = doc.get("colors") as List<dynamic>;
  return colorsData
      .map((interval) =>
          RangeInterval.fromFirestore(interval as Map<String, dynamic>))
      .toList();
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
