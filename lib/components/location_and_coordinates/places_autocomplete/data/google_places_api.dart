import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:weather_blanket/components/location_and_coordinates/places_autocomplete/model/place_details.dart';
import 'package:weather_blanket/components/location_and_coordinates/places_autocomplete/model/prediction.dart';

class GooglePlacesApi {
  Future<PlacesAutocompleteResponse?> getSuggestionsForInput({
    required String input,
    String? sessionToken,
    String? languageCode,
  }) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getPlacesSuggestions')
          .call({
        'input': input,
        'languageCode': languageCode,
        'sessionToken': sessionToken,
      });

      return PlacesAutocompleteResponse.fromJson(result.data);
    } catch (e) {
      debugPrint('GooglePlacesApi.getSuggestionsForInput: ${e.toString()}');
      return null;
    }
  }

  Future<Prediction?> fetchCoordinatesForPrediction({
    required Prediction prediction,
    String? sessionToken,
  }) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getPlaceDetails')
          .call({
        'placeId': prediction.placeId,
        'sessionToken': sessionToken,
      });

      final placeDetails = PlaceDetails.fromJson(result.data);
      prediction.lat = placeDetails.result!.geometry!.location!.lat.toString();
      prediction.lng = placeDetails.result!.geometry!.location!.lng.toString();

      return prediction;
    } catch (e) {
      debugPrint(
          'GooglePlacesApi.fetchCoordinatesForPrediction: ${e.toString()}');
      return null;
    }
  }
}
