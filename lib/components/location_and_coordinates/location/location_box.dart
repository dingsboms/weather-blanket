import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/components/location_and_coordinates/location/location_text_field.dart';
import 'package:weather_blanket/models/weather_data.dart';

class LocationBox extends StatefulWidget {
  const LocationBox({super.key, required this.userId, this.weatherItem});
  final String userId;
  final WeatherForecast? weatherItem;

  @override
  State<LocationBox> createState() => _LocationBoxState();
}

class _LocationBoxState extends State<LocationBox> {
  final longitudeController = TextEditingController();
  final lattitudeController = TextEditingController();
  bool showButton = false;
  late double lattitudeBeforeUpdate;
  late double longitudeBeforeUpdate;
  bool isLoading = false;
  late Future<GeoPoint> _locationFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState
    _locationFuture = _initializeLocation();
    longitudeController.addListener(_onTextChanged);
    lattitudeController.addListener(_onTextChanged);
  }

  Future<GeoPoint> _initializeLocation() async {
    if (widget.weatherItem != null) {
      GeoPoint location = widget.weatherItem!.temperatureLocation;
      _updateLattitudeAndLongitudeBeforeUpdate(location);
      return location;
    } else {
      final fetchedLocation = await _fetchUserData();
      if (fetchedLocation == null) {
        throw Exception("Failed to fetch user data location");
      }
      return fetchedLocation;
    }
  }

  _updateLattitudeAndLongitudeBeforeUpdate(GeoPoint location) {
    lattitudeBeforeUpdate = location.latitude;
    longitudeBeforeUpdate = location.longitude;
    lattitudeController.text = location.latitude.toString();
    longitudeController.text = location.longitude.toString();
  }

  @override
  void dispose() {
    longitudeController.dispose();
    lattitudeController.dispose();
    super.dispose();
  }

  Future<GeoPoint?> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();

      if (doc.exists && doc.data()!.containsKey('temperature_location')) {
        final geoPoint = doc.get('temperature_location') as GeoPoint;
        setState(() {
          _updateLattitudeAndLongitudeBeforeUpdate(geoPoint);
        });
        return geoPoint;
      } else {
        throw Exception(
            "Failed getting userData Location: doc does not exist or does not contain key temperature_location");
      }
    } catch (e) {
      throw Exception("Failed getting userData Location: $e");
    }
  }

  void _onTextChanged() {
    bool latitudeChanged = false;
    bool longitudeChanged = false;

    try {
      final currentLatitude = double.parse(lattitudeController.text);
      final currentLongitude = double.parse(longitudeController.text);

      latitudeChanged = (currentLatitude - lattitudeBeforeUpdate).abs() > 0e-5;
      longitudeChanged =
          (currentLongitude - longitudeBeforeUpdate).abs() > 0e-5;
    } catch (e) {
      latitudeChanged = true;
      longitudeChanged = true;
    }

    if (mounted) {
      setState(() {
        showButton = latitudeChanged || longitudeChanged;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool workingOnDefaultLocation = widget.weatherItem == null;

    return FutureBuilder<GeoPoint>(
      future: _locationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No location data available'));
        }

        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pin emoji column
              const Column(
                children: [
                  SizedBox(
                    height: 30,
                    width: 40,
                  ), // Align with labels
                  Text(
                    "📍",
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ],
              ),
              // Latitude column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Latitude",
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                  LocationTextField(
                    isLatitude: true,
                    controller: lattitudeController,
                  ),
                ],
              ),
              const SizedBox(width: 16), // Space between fields
              // Longitude column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Longitude",
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                  LocationTextField(
                    isLatitude: false,
                    controller: longitudeController,
                  ),
                ],
              ),
              // Button column
              Column(
                children: [
                  const SizedBox(height: 20), // Align with labels
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    onPressed: showButton
                        ? workingOnDefaultLocation
                            ? () async {
                                setState(() => isLoading = true);
                                final newPosition = GeoPoint(
                                    double.parse(lattitudeController.text),
                                    double.parse(longitudeController.text));
                                await updateDefaultPosition(
                                    widget.userId, newPosition);
                                await _fetchUserData();
                                setState(() => isLoading = false);
                              }
                            : () async {
                                setState(() => isLoading = true);
                                final newPosition = GeoPoint(
                                    double.parse(lattitudeController.text),
                                    double.parse(longitudeController.text));
                                await updateItemLocation(
                                    widget.userId,
                                    widget.weatherItem!.docId,
                                    newPosition,
                                    widget.weatherItem!.dt);

                                setState(() {
                                  isLoading = false;
                                  _updateLattitudeAndLongitudeBeforeUpdate(
                                      newPosition);
                                });
                              }
                        : null,
                    child: isLoading
                        ? const CupertinoActivityIndicator()
                        : const Text("🔄"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateItemLocation(String userId, String docId,
      GeoPoint newGeoPoint, DateTime dateTime) async {
    final updatedDoc = await WeatherForecast.fromOpenWeatherAPI(
        dateTime: dateTime, docId: docId, location: newGeoPoint);
    if (updatedDoc == null) {
      throw Exception("Failed to get updatedDoc fomr OpenWeatherAPI");
    }

    print("Got updated doc: $updatedDoc");
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("days")
        .doc(docId)
        .set(updatedDoc.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateDefaultPosition(
      String userId, GeoPoint newGeoPoint) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set({"temperature_location": newGeoPoint}, SetOptions(merge: true));
  }
}
