import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WeatherForecast {
  final GeoPoint temperatureLocation;
  String? temperatureLocationName;
  final String timezone;
  final int timezoneOffset;
  final String docId;
  final DateTime dt;
  final int temp;
  final double feelsLike;
  final int pressure;
  final int humidity;
  final double dewPoint;
  final int uvi;
  final int clouds;
  final int visibility;
  final double windSpeed;
  final int windDeg;
  final double windGust;
  final int sunrise;
  final int sunset;
  final int weatherId;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final bool isKnitted;
  final String knittingNote;

  WeatherForecast({
    this.temperatureLocationName,
    required this.temperatureLocation,
    required this.timezone,
    required this.timezoneOffset,
    required this.docId,
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.dewPoint,
    required this.uvi,
    required this.clouds,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    required this.windGust,
    required this.sunrise,
    required this.sunset,
    required this.weatherId,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.isKnitted,
    required this.knittingNote,
  });

  DateTime get localDate => dt.toLocal();
  bool get isNewMonth => localDate.day == 1;
  static Future<WeatherForecast?> fromOpenWeatherAPI(
      {required DateTime dateTime,
      required String docId,
      GeoPoint? location}) async {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Error user not logged in");
    }

    // Get location from Firestore if not provided
    if (location == null) {
      final temperatureLocationDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      location = temperatureLocationDoc.get("temperature_location");

      if (location == null) {
        throw Exception("Failed to get location");
      }
    }

    // Prepare parameters for the cloud function
    final lat = location.latitude;
    final lon = location.longitude;
    final dateUtc = dateTime.toUtc().millisecondsSinceEpoch ~/ 1000;

    try {
      // Call the Firebase Cloud Function instead of direct API call
      final functions = FirebaseFunctions.instance;
      final result =
          await functions.httpsCallable('fetchOpenWeatherData').call({
        'date': dateUtc,
        'lat': lat,
        'lon': lon,
      });

      // Parse the response
      if (result.data != null) {
        return WeatherForecast._fromAPIResponse(result.data, docId);
      } else {
        throw Exception('Weather data is null');
      }
    } catch (e) {
      debugPrint('WeatherForecast.fromOpenWeatherAPI: ${e.toString()}');
      throw Exception('Failed to load weather data: $e');
    }
  }

  // Private constructor for API response
  factory WeatherForecast._fromAPIResponse(
      Map<String, dynamic> json, String docId) {
    final data = json['data'][0] as Map<String, dynamic>;
    final weather = data['weather'][0] as Map<String, dynamic>;

    double lat = (json['lat'] as num).toDouble();
    double lon = (json['lon'] as num).toDouble();

    GeoPoint temperatureLocation = GeoPoint(lat, lon);
    try {
      final result = WeatherForecast(
        temperatureLocation: temperatureLocation,
        timezone: json['timezone'] as String,
        timezoneOffset: json['timezone_offset'] as int,
        docId: docId,
        dt: DateTime.fromMillisecondsSinceEpoch((data['dt'] as int) * 1000),
        temp: (data['temp'] as num).toInt(),
        feelsLike: (data['feels_like'] as num).toDouble(),
        pressure: (data['pressure'] as num).round(),
        humidity: (data['humidity'] as num).round(),
        dewPoint: (data['dew_point'] as num).toDouble(),
        uvi: data.containsKey('uvi')
            ? (data['uvi'] as num).round()
            : 0, // UVI might not be present
        clouds: (data['clouds'] as num).round(),
        visibility: data.containsKey('visibility')
            ? (data['visibility'] as num).round()
            : 10000, // visibility might not be in this response
        windSpeed: (data['wind_speed'] as num).toDouble(),
        windDeg: (data['wind_deg'] as num).round(),
        windGust: data.containsKey('wind_gust')
            ? (data['wind_gust'] as num).toDouble()
            : 0.0, // wind_gust might not be present
        sunrise: data['sunrise'] as int,
        sunset: data['sunset'] as int,
        weatherId: (weather['id'] as num).round(),
        weatherMain: weather['main'] as String,
        weatherDescription: weather['description'] as String,
        weatherIcon: weather['icon'] as String,
        isKnitted: false,
        knittingNote: '',
      );
      return result;
    } catch (e) {
      print("Failed to parse data: $e");
      throw Exception(e);
    }
  }

  factory WeatherForecast.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime dt;
    try {
      dt = (data['dt'] as Timestamp).toDate();
    } catch (e) {
      dt = DateTime.fromMillisecondsSinceEpoch((data['dt'] as int) * 1000);
    }

    int temp = (data['temp'] as num).toInt();

    final weatherData = WeatherForecast(
      temperatureLocation: data['temperature_location'] as GeoPoint,
      temperatureLocationName: data['temperature_location_name'],
      timezone: data['timezone'] as String,
      timezoneOffset: data['timezone_offset'] as int,
      docId: doc.id,
      dt: dt,
      temp: temp,
      feelsLike: (data['feels_like'] as num).toDouble(),
      pressure: data['pressure'] as int,
      humidity: data['humidity'] as int,
      dewPoint: (data['dew_point'] as num).toDouble(),
      uvi: data['uvi'] as int,
      clouds: data['clouds'] as int,
      visibility: data['visibility'] as int,
      windSpeed: (data['wind_speed'] as num).toDouble(),
      windDeg: data['wind_deg'] as int,
      windGust: (data['wind_gust'] as num).toDouble(),
      sunrise: data['sunrise'] as int,
      sunset: data['sunset'] as int,
      weatherId: data['weather_id'] as int,
      weatherMain: data['weather_main'] as String,
      weatherDescription: data['weather_description'] as String,
      weatherIcon: data['weather_icon'] as String,
      isKnitted: data['is_knitted'] ?? false,
      knittingNote: data['knitting_note'] ?? '',
    );

    return weatherData;
  }

  Map<String, dynamic> toFirestore() => {
        'temperature_location': temperatureLocation,
        'temperature_location_name': temperatureLocationName,
        'timezone': timezone,
        'timezone_offset': timezoneOffset,
        'dt': dt,
        'temp': temp,
        'feels_like': feelsLike,
        'pressure': pressure,
        'humidity': humidity,
        'dew_point': dewPoint,
        'uvi': uvi,
        'clouds': clouds,
        'visibility': visibility,
        'wind_speed': windSpeed,
        'wind_deg': windDeg,
        'wind_gust': windGust,
        'sunrise': sunrise,
        'sunset': sunset,
        'weather_id': weatherId,
        'weather_main': weatherMain,
        'weather_description': weatherDescription,
        'weather_icon': weatherIcon,
        'is_knitted': isKnitted,
        'knitting_note': knittingNote,
      };

  @override
  String toString() {
    return 'WeatherForecast(docId: $docId, dt: ${dt.toIso8601String()}, temp: $temp°C, '
        'weather: $weatherMain ($weatherDescription), lat: ${temperatureLocation.latitude}, lon: ${temperatureLocation.longitude}, '
        'isKnitted: $isKnitted, knittingNote: $knittingNote';
  }
}
