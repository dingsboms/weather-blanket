import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:weather_blanket/places_auto_complete/model/prediction.dart';
import 'package:weather_blanket/places_auto_complete/widgets/google_places_autocomplete_text_field.dart';

class MyGoogleAutocompleteTextField extends StatefulWidget {
  const MyGoogleAutocompleteTextField({super.key});

  @override
  State<MyGoogleAutocompleteTextField> createState() =>
      _PlacesSearchScreenState();
}

class _PlacesSearchScreenState extends State<MyGoogleAutocompleteTextField> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedPlace;
  String? _coordinates;
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    // Generate a session token when the search screen initializes
    _refreshSessionToken();
  }

  void _refreshSessionToken() {
    // Create a unique session token using the uuid package
    _sessionToken = const Uuid().v4();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: 200,
        child: Column(
          children: [
            const Text("Location"),
            GooglePlacesAutoCompleteTextFormField(
              textEditingController: _controller,
              sessionToken: _sessionToken,
              debounceTime: 500,
              minInputLength: 2,
              languageCode: 'en',
              style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 16,
              ),
              predictionsStyle: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 14,
              ),
              onSuggestionClicked: (Prediction prediction) {
                setState(() {
                  _selectedPlace = prediction.description;
                  if (_selectedPlace != null) {
                    _controller.text = _selectedPlace!;
                  }
                });
              },
              onPlaceDetailsWithCoordinatesReceived: (Prediction prediction) {
                setState(() {
                  _coordinates = '${prediction.lat}, ${prediction.lng}';
                  _refreshSessionToken();
                });
              },
              onError: (error) {
                // Show Cupertino-style alert
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Error'),
                    content: Text('$error'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
              // Override with Cupertino-style container if needed
              overlayContainerBuilder: (child) => Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: CupertinoColors.systemGrey5),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedPlace != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected Place: $_selectedPlace',
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            if (_coordinates != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Coordinates: $_coordinates',
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
