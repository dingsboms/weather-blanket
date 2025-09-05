import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tempestry/components/color/user_temperature_multi_slider.dart';
import 'package:tempestry/components/location_and_coordinates/location_and_autocomplete.dart';
import 'package:tempestry/functions/color_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileScreen(
      auth: FirebaseAuth.instance,
      cupertinoNavigationBar: CupertinoNavigationBar(
        enableBackgroundFilterBlur: false,
        backgroundColor: CupertinoColors.transparent,
        leading: CupertinoButton(
            child: const Icon(Icons.arrow_back),
            onPressed: () => context.pop()),
      ),
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
      children: [
        const LocationAndAutocomplete(),
        const SizedBox(height: 16),
        UserTemperatureMultiSlider(),
      ],
    );
  }
}
