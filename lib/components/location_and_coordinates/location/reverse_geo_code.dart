import 'dart:convert';

/// A class to handle reverse geocoding responses from Google Maps API
class ReverseGeocode {
  final PlusCode? plusCode;
  final List<GeocodingResult> results;
  final String status;
  final String? errorMessage;

  ReverseGeocode({
    this.plusCode,
    required this.results,
    required this.status,
    this.errorMessage,
  });

  /// Create a ReverseGeocode object from a JSON map
  factory ReverseGeocode.fromJson(Map<String, dynamic> json) {
    final plusCodeJson = json['plus_code'];
    final PlusCode? plusCode =
        plusCodeJson != null ? PlusCode.fromJson(plusCodeJson) : null;

    final List<dynamic> resultsJson = json['results'] ?? [];
    final List<GeocodingResult> results = resultsJson
        .map((resultJson) => GeocodingResult.fromJson(resultJson))
        .toList();

    final String status = json['status'] ?? '';
    final String? errorMessage = json['error_message'];

    return ReverseGeocode(
      plusCode: plusCode,
      results: results,
      status: status,
      errorMessage: errorMessage,
    );
  }

  /// Create a ReverseGeocode object from a JSON string
  factory ReverseGeocode.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return ReverseGeocode.fromJson(json);
  }

  bool get isSuccess => status == 'OK';

  String? get formattedAddress =>
      results.isNotEmpty ? results[0].formattedAddress : null;

  String? get locality => _findAddressComponent('locality');

  String? get administrativeArea =>
      _findAddressComponent('administrative_area_level_1');

  String? get country => _findAddressComponent('country');

  String? get postalCode => _findAddressComponent('postal_code');

  String? _findAddressComponent(String type) {
    if (results.isEmpty) return null;

    for (var result in results) {
      for (var component in result.addressComponents) {
        if (component.types.contains(type)) {
          return component.longName;
        }
      }
    }
    return null;
  }
}

/// Represents a single result in a geocoding response
class GeocodingResult {
  final List<AddressComponent> addressComponents;
  final String formattedAddress;
  final Geometry geometry;
  final String placeId;
  final PlusCode? plusCode;
  final List<String> types;

  GeocodingResult({
    required this.addressComponents,
    required this.formattedAddress,
    required this.geometry,
    required this.placeId,
    this.plusCode,
    required this.types,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> componentsJson = json['address_components'] ?? [];
    final List<AddressComponent> addressComponents = componentsJson
        .map((componentJson) => AddressComponent.fromJson(componentJson))
        .toList();

    final String formattedAddress = json['formatted_address'] ?? '';

    final geometryJson = json['geometry'] ?? {};
    final Geometry geometry = Geometry.fromJson(geometryJson);

    final String placeId = json['place_id'] ?? '';

    final plusCodeJson = json['plus_code'];
    final PlusCode? plusCode =
        plusCodeJson != null ? PlusCode.fromJson(plusCodeJson) : null;

    final List<dynamic> typesJson = json['types'] ?? [];
    final List<String> types = typesJson.cast<String>();

    return GeocodingResult(
      addressComponents: addressComponents,
      formattedAddress: formattedAddress,
      geometry: geometry,
      placeId: placeId,
      plusCode: plusCode,
      types: types,
    );
  }
}

/// Represents an address component in a geocoding result
class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    final String longName = json['long_name'] ?? '';
    final String shortName = json['short_name'] ?? '';
    final List<dynamic> typesJson = json['types'] ?? [];
    final List<String> types = typesJson.cast<String>();

    return AddressComponent(
      longName: longName,
      shortName: shortName,
      types: types,
    );
  }
}

/// Represents the geometry information in a geocoding result
class Geometry {
  final Bounds? bounds;
  final Location location;
  final String locationType;
  final Viewport viewport;

  Geometry({
    this.bounds,
    required this.location,
    required this.locationType,
    required this.viewport,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    final boundsJson = json['bounds'];
    final Bounds? bounds =
        boundsJson != null ? Bounds.fromJson(boundsJson) : null;

    final locationJson = json['location'] ?? {};
    final Location location = Location.fromJson(locationJson);

    final String locationType = json['location_type'] ?? '';

    final viewportJson = json['viewport'] ?? {};
    final Viewport viewport = Viewport.fromJson(viewportJson);

    return Geometry(
      bounds: bounds,
      location: location,
      locationType: locationType,
      viewport: viewport,
    );
  }
}

/// Represents a location with latitude and longitude
class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    final double lat =
        (json['lat'] is num) ? (json['lat'] as num).toDouble() : 0.0;
    final double lng =
        (json['lng'] is num) ? (json['lng'] as num).toDouble() : 0.0;

    return Location(
      lat: lat,
      lng: lng,
    );
  }
}

/// Represents the bounds of a location
class Bounds {
  final Location northeast;
  final Location southwest;

  Bounds({
    required this.northeast,
    required this.southwest,
  });

  factory Bounds.fromJson(Map<String, dynamic> json) {
    final northeastJson = json['northeast'] ?? {};
    final northeast = Location.fromJson(northeastJson);

    final southwestJson = json['southwest'] ?? {};
    final southwest = Location.fromJson(southwestJson);

    return Bounds(
      northeast: northeast,
      southwest: southwest,
    );
  }
}

/// Represents the viewport of a location
class Viewport {
  final Location northeast;
  final Location southwest;

  Viewport({
    required this.northeast,
    required this.southwest,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) {
    final northeastJson = json['northeast'] ?? {};
    final northeast = Location.fromJson(northeastJson);

    final southwestJson = json['southwest'] ?? {};
    final southwest = Location.fromJson(southwestJson);

    return Viewport(
      northeast: northeast,
      southwest: southwest,
    );
  }
}

/// Represents a Plus Code in a geocoding result
class PlusCode {
  final String compoundCode;
  final String globalCode;

  PlusCode({
    required this.compoundCode,
    required this.globalCode,
  });

  factory PlusCode.fromJson(Map<String, dynamic> json) {
    final String compoundCode = json['compound_code'] ?? '';
    final String globalCode = json['global_code'] ?? '';

    return PlusCode(
      compoundCode: compoundCode,
      globalCode: globalCode,
    );
  }
}
