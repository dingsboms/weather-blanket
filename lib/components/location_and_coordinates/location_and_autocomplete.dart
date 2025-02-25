import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/components/location_and_coordinates/location/location_box.dart';
import 'package:weather_blanket/components/location_and_coordinates/places_autocomplete/my_google_autocomplete_text_field.dart';

class LocationAndAutocomplete extends StatefulWidget {
  const LocationAndAutocomplete({super.key});

  @override
  State<LocationAndAutocomplete> createState() =>
      _LocationAndAutocompleteState();
}

class _LocationAndAutocompleteState extends State<LocationAndAutocomplete> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MyGoogleAutocompleteTextField(),
      LocationBox(userId: userId)
    ]);
  }
}
