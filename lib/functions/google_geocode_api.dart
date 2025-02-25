import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

class GeoCodeGoogleData {
  final String formattedAddress;
  final String placeId;
  final GeoPoint location;

  GeoCodeGoogleData(
      {required this.formattedAddress,
      required this.placeId,
      required this.location});

  Map<String, dynamic> toFirestore() {
    return {
      "place_id": placeId,
      "formatted_address": formattedAddress,
      "location": location
    };
  }

  @override
  String toString() {
    return "formattedAddress: $formattedAddress, placeId: $placeId, location: $location";
  }
}

Future<List<GeoCodeGoogleData>> getGeopointFromAddress(String address) async {
  final geoLocationsDbRef =
      FirebaseFirestore.instance.collection("geoLocations");

  // Check firestore first, to reduce external API-costs
  geoLocationsDbRef
      .where("long_names", arrayContains: address)
      .get()
      .then((hits) async {
    if (hits.docs.isEmpty) {
      print("No hits, trying the external API");
      return await getGeoPointExternally(address);
    }

    List<GeoCodeGoogleData> geoCodes = [];
    for (var doc in hits.docs) {
      final res = parseData(doc.data());
      geoCodes.add(res);
    }
    return geoCodes;
  });
  return [];
}

Future<List<GeoCodeGoogleData>> getGeoPointExternally(String address) async {
  final functions = FirebaseFunctions.instance;

  final response = await functions
      .httpsCallable("getGeoLocationFromAddress")
      .call({'address': address});

  final results = response.data['results'];

  List<GeoCodeGoogleData> geoDataList = [];
  for (var result in results) {
    final geoData = parseData(result);
    geoDataList.add(geoData);
  }

  return geoDataList;
}

GeoCodeGoogleData parseData(Map<String, dynamic> data) {
  try {
    String formattedAddress = data['formatted_address'];
    String placeId = data['place_id'];
    Map<String, dynamic> geometry = data['geometry'];
    Map<String, dynamic> locationMap = geometry['location'];
    double lat = (locationMap['lat'] as num).toDouble();
    double lon = (locationMap['lng'] as num).toDouble();

    GeoPoint location = GeoPoint(lat, lon);

    GeoCodeGoogleData entry = GeoCodeGoogleData(
        formattedAddress: formattedAddress,
        placeId: placeId,
        location: location);

    return entry;
  } catch (e) {
    throw Exception("Failed to fetch geolocation from address $e");
  }
}

class TestGeopointFromAdressEndpoint extends StatefulWidget {
  const TestGeopointFromAdressEndpoint({super.key, this.address});
  final String? address;

  @override
  State<TestGeopointFromAdressEndpoint> createState() =>
      _TestGeopointFromAdressEndpointState();
}

class _TestGeopointFromAdressEndpointState
    extends State<TestGeopointFromAdressEndpoint> {
  @override
  Widget build(BuildContext context) {
    String address = widget.address ?? "Oslo";

    return CupertinoButton(
      onPressed: () => onPressed(address),
      child: Text("Test Geopoint from Address endpoint with $address"),
    );
  }

  onPressed(String address) async {
    final geoCodes = await getGeopointFromAddress(address);
    for (var code in geoCodes) {
      print(code);
    }
  }
}
