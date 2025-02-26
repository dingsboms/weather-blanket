import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/color/color_segments.dart';
import 'package:weather_blanket/components/location_and_coordinates/location_and_autocomplete.dart';
import 'package:weather_blanket/functions/color_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, required this.auth});
  final FirebaseAuth auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: CupertinoButton(
              child: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                LocationAndAutocomplete(),
                const Divider(),
                ColorSegments(
                  userId: auth.currentUser!.uid,
                ),
                const Divider(),
                CupertinoButton(
                    child: const Text("Sign out"),
                    onPressed: () {
                      auth.signOut();
                      Navigator.pop(context);
                      ref.invalidate(colorRangesProvider);
                    })
              ],
            ),
          ),
        ));
  }
}
