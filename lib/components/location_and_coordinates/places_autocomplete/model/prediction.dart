class PlacesAutocompleteResponse {
  List<Prediction>? predictions;
  String? status;

  PlacesAutocompleteResponse({
    this.predictions,
    this.status,
  });

  PlacesAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['predictions'] != null) {
      predictions = [];
      json['predictions'].forEach((v) {
        // Convert each prediction item to proper Map<String, dynamic>
        final predictionMap = Map<String, dynamic>.from(v);
        predictions!.add(Prediction.fromJson(predictionMap));
      });
    }
  }
}

class Prediction {
  String? description;
  String? placeId;
  String? reference;
  StructuredFormatting? structuredFormatting;
  List<String>? types;
  String? lat;
  String? lng;

  Prediction({
    this.description,
    this.placeId,
    this.reference,
    this.structuredFormatting,
    this.types,
    this.lat,
    this.lng,
  });

  Prediction.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    placeId = json['place_id'];
    reference = json['reference'];

    if (json['structured_formatting'] != null) {
      // Convert the nested map to proper Map<String, dynamic>
      final structuredFormattingMap =
          Map<String, dynamic>.from(json['structured_formatting']);
      structuredFormatting =
          StructuredFormatting.fromJson(structuredFormattingMap);
    } else {
      structuredFormatting = null;
    }

    types = json['types']?.cast<String>();
  }
}

class MatchedSubstrings {
  int? length;
  int? offset;

  MatchedSubstrings({this.length, this.offset});

  MatchedSubstrings.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }
}

class StructuredFormatting {
  String? mainText;
  String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  StructuredFormatting.fromJson(Map<String, dynamic> json) {
    mainText = json['main_text'];
    secondaryText = json['secondary_text'];
  }
}

class Terms {
  int? offset;
  String? value;

  Terms({this.offset, this.value});

  Terms.fromJson(Map<String, dynamic> json) {
    offset = json['offset'];
    value = json['value'];
  }
}
