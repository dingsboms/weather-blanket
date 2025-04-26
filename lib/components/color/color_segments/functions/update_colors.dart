// Returns success true / false
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/color/color_segments/functions/intervals_overlap.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/models/range_interval.dart';

// Returns success true / false
Future<bool> updateColors(List<RangeInterval> colors, WidgetRef ref) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  if (intervalsOverlap(colors)) {
    print('Intervals overlap detected');
    return false;
  }
  final intervalsFirestoreList =
      colors.map((interval) => interval.toFiretore()).toList();

  try {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set({"colors": intervalsFirestoreList}, SetOptions(merge: true));
    print('Firestore update successful');
    ref.invalidate(colorRangesProvider);
    return true;
  } catch (e) {
    print('Error updating Firestore: $e');
    return false;
  }
}
