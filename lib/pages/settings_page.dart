import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_blanket/components/color/color_segments/color_segments_settings.dart';
import 'package:weather_blanket/components/location_and_coordinates/location_and_autocomplete.dart';
import 'package:weather_blanket/functions/color_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = FirebaseAuth.instance;

    return ProfileScreen(
      cupertinoNavigationBar: CupertinoNavigationBar(
        enableBackgroundFilterBlur: false,
        backgroundColor: CupertinoColors.transparent,
        leading: CupertinoButton(
            child: const Icon(Icons.arrow_back),
            onPressed: () => context.pop()),
      ),
      auth: auth,
      actions: [
        SignedOutAction((context) {
          ref.invalidate(colorRangesProvider);
          context.go("/login");
        }),
        AccountDeletedAction(
          (context, state) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(state.uid)
                .delete();
            print("Account deleted: ${state.uid}");
          },
        )
      ],
      showUnlinkConfirmationDialog: true,
      showDeleteConfirmationDialog: true,
      children: const [
        LocationAndAutocomplete(),
        SizedBox(height: 16),
        ColorSegmentsSettings(),
      ],
    );
  }
}
