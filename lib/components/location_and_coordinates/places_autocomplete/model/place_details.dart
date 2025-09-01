class PlaceDetails {
  Result? result;
  String? status;
  List<String>? htmlAttributions;

  PlaceDetails({this.result, this.status, this.htmlAttributions});

  PlaceDetails.fromJson(Map<String, dynamic> json) {
    result = json['result'] != null
        ? Result.fromJson(Map<String, dynamic>.from(json['result']))
        : null;
    status = json['status'];
    htmlAttributions = json['html_attributions']?.cast<String>();
  }

  @override
  String toString() {
    final lat = result?.geometry?.location?.lat;
    final lng = result?.geometry?.location?.lng;
    final coords = (lat != null && lng != null)
        ? 'lat: $lat, lng: $lng'
        : 'no coordinates';

    return 'PlaceDetails(status: $status, coordinates: $coords)';
  }
}

class Result {
  Geometry? geometry;

  Result({this.geometry});

  Result.fromJson(Map<String, dynamic> json) {
    geometry = json['geometry'] != null
        ? Geometry.fromJson(Map<String, dynamic>.from(json['geometry']))
        : null;
  }
}

class Geometry {
  Location? location;
  Viewport? viewport;

  Geometry({this.location, this.viewport});

  Geometry.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? Location.fromJson(Map<String, dynamic>.from(json['location']))
        : null;
    viewport = json['viewport'] != null
        ? Viewport.fromJson(Map<String, dynamic>.from(json['viewport']))
        : null;
  }
}

class Location {
  double? lat;
  double? lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }
}

class Viewport {
  Location? northeast;
  Location? southwest;

  Viewport({this.northeast, this.southwest});

  Viewport.fromJson(Map<String, dynamic> json) {
    northeast = json['northeast'] != null
        ? Location.fromJson(Map<String, dynamic>.from(json['northeast']))
        : null;
    southwest = json['southwest'] != null
        ? Location.fromJson(Map<String, dynamic>.from(json['southwest']))
        : null;
  }
}
