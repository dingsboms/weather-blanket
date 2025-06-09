import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:tempestry/components/location_and_coordinates/places_autocomplete/model/prediction.dart';
import 'package:tempestry/components/location_and_coordinates/places_autocomplete/widgets/google_places_autocomplete_text_field.dart';

class MyGoogleAutocompleteTextField extends StatefulWidget {
  const MyGoogleAutocompleteTextField(
      {super.key,
      required this.controller,
      required this.onSuggestionClicked,
      this.initialText});
  final TextEditingController controller;
  final Function(Prediction predicton) onSuggestionClicked;
  final String? initialText;

  @override
  State<MyGoogleAutocompleteTextField> createState() =>
      _PlacesSearchScreenState();
}

class _PlacesSearchScreenState extends State<MyGoogleAutocompleteTextField> {
  late TextEditingController _controller;
  String? _selectedPlace;
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    // Generate a session token when the search screen initializes
    _refreshSessionToken();
    _controller = widget.controller;
    _controller.text = widget.initialText ?? _controller.text;
  }

  void _refreshSessionToken() {
    // Create a unique session token using the uuid package
    _sessionToken = const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          const Text("Location"),
          GooglePlacesAutoCompleteTextFormField(
            textEditingController: _controller,
            sessionToken: _sessionToken,
            debounceTime: 500,
            minInputLength: 2,
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
                _refreshSessionToken();
              });
              widget.onSuggestionClicked(prediction);
            },
            onError: (error) {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Error'),
                  content: Text('$error'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
