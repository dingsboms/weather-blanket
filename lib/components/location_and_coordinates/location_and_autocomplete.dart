import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/components/location_and_coordinates/location/location_box.dart';
import 'package:weather_blanket/components/location_and_coordinates/location/reverse_geo_code.dart';
import 'package:weather_blanket/components/location_and_coordinates/places_autocomplete/my_google_autocomplete_text_field.dart';
import 'package:weather_blanket/models/weather_data.dart';

class LocationAndAutocomplete extends StatefulWidget {
  const LocationAndAutocomplete({super.key, this.weatherItem});
  final WeatherForecast? weatherItem;

  @override
  State<LocationAndAutocomplete> createState() =>
      _LocationAndAutocompleteState();
}

class _LocationAndAutocompleteState extends State<LocationAndAutocomplete> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final _lattitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _autoCompleteController = TextEditingController();
  String initialLocationName = "";
  late bool isWeatherItemLocationBox;

  @override
  void dispose() {
    _lattitudeController.dispose();
    _longitudeController.dispose();
    _autoCompleteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    isWeatherItemLocationBox = widget.weatherItem != null;
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("users").doc(userId);

    if (isWeatherItemLocationBox) {
      documentReference =
          documentReference.collection("days").doc(widget.weatherItem!.docId);
    }

    try {
      documentReference.get().then((doc) {
        fetchTemperatureLocationName(doc).then((locName) {
          if (mounted) {
            setState(() {
              initialLocationName = locName;
            });
          }
        });
      });
    } catch (e) {
      // Handle document fetch error silently in production
      // Consider logging to a proper logging service
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MyGoogleAutocompleteTextField(
        key: Key(initialLocationName),
        initialText: initialLocationName,
        controller: _autoCompleteController,
        onSuggestionClicked: (predicton) {
          if (predicton.lat != null && predicton.lng != null) {
            try {
              double lat = double.parse(predicton.lat!);
              double lng = double.parse(predicton.lng!);
              setState(() {
                _lattitudeController.text = lat.toStringAsFixed(4);
                _longitudeController.text = lng.toStringAsFixed(4);
              });
            } catch (e) {
              // Handle coordinate parsing error silently in production
              // Consider logging to a proper logging service
            }
          }
        },
      ),
      LocationBox(
          userId: userId,
          lattitudeController: _lattitudeController,
          longitudeController: _longitudeController,
          weatherItem: widget.weatherItem,
          onUpdate: (location) async {
            String address = await fetchAddressFromGeoLocation(location);
            if (mounted) {
              setState(() {
                _autoCompleteController.text = address;
              });
            }
          })
    ]);
  }
}

Future<String> fetchTemperatureLocationName(DocumentSnapshot doc) async {
  String locationName = "";

  try {
    locationName = await doc.get("temperature_location_name");
  } catch (e) {
    // Handle temperature location name fetch error silently in production
    // Consider logging to a proper logging service

    try {
      GeoPoint location = doc.get("temperature_location");
      locationName = await fetchAddressFromGeoLocation(location);
      doc.reference.set(
          {"temperature_location_name": locationName}, SetOptions(merge: true));
    } catch (e) {
      // Handle reverse geocoding error silently in production
      // Consider logging to a proper logging service
    }
  }

  return locationName;
}

Future<String> fetchAddressFromGeoLocation(GeoPoint location) async {
  double lat = location.latitude;
  double lon = location.longitude;
  final res = await FirebaseFunctions.instance
      .httpsCallable("getAddressFromGeoLocation")
      .call({"lat": lat, "lon": lon});

  final reverseGeocode = ReverseGeocode.fromJson(res.data);
  if (reverseGeocode.isSuccess) {
    // Location coordinates available if needed
    // final location = reverseGeocode.results[0].geometry.location;

    return reverseGeocode.formattedAddress!;
  } else {
    // Handle geocoding error silently in production
    // Consider logging to a proper logging service
  }
  throw Exception(reverseGeocode.errorMessage);
}
