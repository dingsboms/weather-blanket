import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather_blanket/components/color/get_default_colors.dart';
import 'package:weather_blanket/models/range_interval.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("User not logged in");
  }
  final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

  final doc = await docRef.get();

  if (!doc.exists) {
    await createNewUserDocumentWithDefaults(docRef, user);
    return await docRef.get();
  }

  return doc;
}

Future<void> createNewUserDocumentWithDefaults(
    DocumentReference userDoc, User user) async {
  String userId = user.uid;
  List<RangeInterval> colors = await getDefaultColors();

  List<dynamic> colorsFirestore = colors.map((e) => e.toFiretore()).toList();

  await userDoc.set({
    'uid': userId,
    'email': user.email,
    'displayName': user.displayName,
    'photoURL': user.photoURL,
    'createdAt': FieldValue.serverTimestamp(),
    'lastLogin': FieldValue.serverTimestamp(),
    'colors': colorsFirestore,
    'temperature_location': const GeoPoint(59.9139, 10.7522)
  });
}
