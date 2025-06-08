import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("User not logged in");
  }
  final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

  final doc = await docRef.get();

  // Fail-safe, this shouldnt occur as firebase functions should create the user document on sign up
  // but in case it does, we create a new user document with default values
  if (!doc.exists) {
    await createNewUserDocumentWithDefaults(docRef, user);
    return await docRef.get();
  }

  return doc;
}

Future<void> createNewUserDocumentWithDefaults(
    DocumentReference userDoc, User user) async {
  String userId = user.uid;

  await userDoc.set({
    'uid': userId,
    'email': user.email,
    'displayName': user.displayName,
    'photoURL': user.photoURL,
    'createdAt': FieldValue.serverTimestamp(),
    'lastLogin': FieldValue.serverTimestamp(),
  });
}
