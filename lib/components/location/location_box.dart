import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/components/location/location_text_field.dart';

class LocationBox extends StatefulWidget {
  const LocationBox({super.key, required this.userId});
  final String userId;

  @override
  State<LocationBox> createState() => _LocationBoxState();
}

class _LocationBoxState extends State<LocationBox> {
  final longitudeController = TextEditingController();
  final lattitudeController = TextEditingController();
  bool showButton = false; // Initialize showButton here
  double originalLattitudeValue = 59.972175;
  double originalLongitudeValue = 10.775647;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    longitudeController.addListener(_onTextChanged);
    lattitudeController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    longitudeController.dispose();
    lattitudeController.dispose();
    super.dispose();
  }

  void _fetchUserData() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get()
        .then(
      (doc) {
        GeoPoint geoPoint;
        if (doc.exists && doc.data()!.containsKey('temperature_location')) {
          geoPoint = doc.get('temperature_location') as GeoPoint;
        } else {
          geoPoint = GeoPoint(originalLattitudeValue, originalLongitudeValue);
        }

        setState(() {
          originalLattitudeValue = geoPoint.latitude;
          lattitudeController.text = geoPoint.latitude.toStringAsFixed(4);
          originalLongitudeValue = geoPoint.longitude;
          longitudeController.text = geoPoint.longitude.toStringAsFixed(4);
        });
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  void _onTextChanged() {
    bool latitudeChanged = false;
    bool longitudeChanged = false;

    try {
      // Parse the current text to double for comparison
      final currentLatitude = double.parse(lattitudeController.text);
      final currentLongitude = double.parse(longitudeController.text);

      // Check if latitude has changed with precision
      latitudeChanged = (currentLatitude - originalLattitudeValue).abs() > 0e-5;

      // Check if longitude has changed with precision
      longitudeChanged =
          (currentLongitude - originalLongitudeValue).abs() > 0e-5;
    } catch (e) {
      // If parsing fails, we assume something has changed or there's invalid input
      latitudeChanged = true;
      longitudeChanged = true;
    }

    // Update showButton based on changes
    setState(() {
      showButton = latitudeChanged || longitudeChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Location: ",
            style: TextStyle(color: CupertinoColors.white),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Latitude",
                style: TextStyle(color: CupertinoColors.white),
              ),
              LocationTextField(
                isLatitude: true,
                controller: lattitudeController,
              )
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Longitude",
                style: TextStyle(color: CupertinoColors.white),
              ),
              LocationTextField(
                isLatitude: false,
                controller: longitudeController,
              )
            ],
          ),
          CupertinoButton(
            onPressed: showButton
                ? () async {
                    await updatePosition(
                      widget.userId,
                      GeoPoint(
                        double.parse(lattitudeController.text),
                        double.parse(longitudeController.text),
                      ),
                    );
                    _fetchUserData(); // Refresh the data after update
                    setState(() {}); // Trigger a rebuild to update the UI
                  }
                : null,
            child: const Text("Update"),
          )
        ],
      ),
    );
  }
}

Future<void> updatePosition(String userId, GeoPoint newGeoPoint) async {
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .set({"temperature_location": newGeoPoint}, SetOptions(merge: true));
}
