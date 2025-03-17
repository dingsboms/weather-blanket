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
        fetchTemperatureLocationName(doc).then((locName) => setState(() {
              initialLocationName = locName;
            }));
      });
    } catch (e) {
      print("Failed $e");
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
              print("Failed to set prediciton.lat or lng to double");
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
            setState(() {
              _autoCompleteController.text = address;
            });
          })
    ]);
  }
}

Future<String> fetchTemperatureLocationName(DocumentSnapshot doc) async {
  String locationName = "";

  try {
    locationName = await doc.get("temperature_location_name");
  } catch (e) {
    print("Failed getting temperature_location_name from firestore");

    try {
      GeoPoint location = doc.get("temperature_location");
      locationName = await fetchAddressFromGeoLocation(location);
      doc.reference.set(
          {"temperature_location_name": locationName}, SetOptions(merge: true));
    } catch (e) {
      print("Failed getting reverse_geocode locationName");
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
    // Access location coordinates
    if (reverseGeocode.results.isNotEmpty) {
      final location = reverseGeocode.results[0].geometry.location;
    }

    return reverseGeocode.formattedAddress!;
  } else {
    print('Error: ${reverseGeocode.errorMessage}');
  }
  throw Exception(reverseGeocode.errorMessage);
}
