import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:weather_blanket/components/color/get_default_clors.dart';
import 'package:weather_blanket/components/login_images.dart';

class LoginPage extends StatefulWidget {
  final FirebaseAuth auth;

  const LoginPage({
    super.key,
    required this.auth,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: kIsWeb
              ? "88468625362-tat400641fh3pnep52la34ar76kq9u0k.apps.googleusercontent.com"
              : null);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _errorMessage = 'Google sign in was cancelled';
          _isLoading = false;
        });
        return;
      }

      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await widget.auth.signInWithCredential(credential);

        final String userId = userCredential.user!.uid;
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(userId);

        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // Create new user document with defaults
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
        } else {
          // Update lastLogin for existing user
          await userDoc.update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        print('Authentication error: $e');
        if (mounted) {
          setState(() {
            _errorMessage = 'Authentication failed: ${e.toString()}';
          });
        }
      }
    } catch (e) {
      print('Google sign in error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Google sign in failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
