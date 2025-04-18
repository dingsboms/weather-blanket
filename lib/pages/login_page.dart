import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:weather_blanket/components/color/get_default_clors.dart';
import 'package:weather_blanket/components/login_images.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String? _errorMessage;

  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> _loginWithGoogle() async {
    initiateLoading();
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      if (kIsWeb) {
        print("kiSWeb true");
        await FirebaseAuth.instance.signInWithRedirect(googleProvider);
      } else {
        print("kiSWeb is not true");

        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          setGoogleSignInError();
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      print('Google sign-in error: $e');
      if (mounted) {
        setError('Google sign-in failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        endLoading();
      }
    }
  }

  createNewUserDocumentWithDefaults(
      DocumentReference userDoc, UserCredential userCredential) async {
    String userId = userCredential.user!.uid;
    await userDoc.set({
      'uid': userId,
      'email': userCredential.user!.email,
      'displayName': userCredential.user!.displayName,
      'photoURL': userCredential.user!.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'colors': getDefaultColors(),
      'temperature_location': const GeoPoint(59.9139, 10.7522)
    });
  }

  updateLastLogin(DocumentReference userDoc) async {
    await userDoc.update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  setError(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
      _isLoading = false;
    });
  }

  setGoogleSignInError() {
    setError('Google sign in was cancelled');
  }

  initiateLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  endLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  double heghtWidth = 250;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Create a Weather-Blanket!",
                    style:
                        TextStyle(fontSize: 32, color: CupertinoColors.white),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 64),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: CupertinoColors.destructiveRed),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_isLoading)
                    const CupertinoActivityIndicator()
                  else
                    CupertinoButton(
                      onPressed: _loginWithGoogle,
                      child: const Text('Login with Google'),
                    ),
                  const LoginImages()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
