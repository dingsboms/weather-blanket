import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:tempestry/components/location_and_coordinates/location/location_box.dart';
import 'package:tempestry/components/location_and_coordinates/location_and_autocomplete.dart';

class ChooseDefaultLocationPage extends StatelessWidget {
  const ChooseDefaultLocationPage({
    super.key,
    required this.onLocationSelected,
  });

  final VoidCallback onLocationSelected;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      context.go('/login');
      return const CupertinoActivityIndicator();
    }
    return CupertinoPageScaffold(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Choose a default location for your temperatures",
            style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
            textAlign: TextAlign.center,
          ),
          LocationAndAutocomplete(
            onUpdate: (geLoc) => updateDefaultPosition(geLoc),
          ),
          CupertinoButton.filled(
              child: const Text("Continue"),
              onPressed: () => onLocationSelected()),
        ],
      )),
    );
  }
}
