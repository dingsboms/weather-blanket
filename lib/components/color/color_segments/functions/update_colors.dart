// Returns success true / false
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tempestry/components/color/color_segments/functions/intervals_overlap.dart';
import 'package:tempestry/functions/color_provider.dart';
import 'package:tempestry/models/range_interval.dart';

// Returns success true / false
Future<bool> updateColors(List<RangeInterval> colors, WidgetRef ref) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  if (intervalsOverlap(colors)) {
    // Intervals overlap detected - handle silently in production
    return false;
  }
  final intervalsFirestoreList =
      colors.map((interval) => interval.toFiretore()).toList();

  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set({"colors": intervalsFirestoreList}, SetOptions(merge: true));
    // Firestore update successful
    ref.invalidate(colorRangesProvider);
    return true;
  } catch (e) {
    // Handle Firestore error silently in production
    // Consider logging to a proper logging service
    return false;
  }
}
