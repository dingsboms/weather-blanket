import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_blanket/models/temperature_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherForecast {
  final double lat;
  final double lon;
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
  final Color? backgroundColor;

  WeatherForecast({
    required this.lat,
    required this.lon,
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
    required this.backgroundColor,
  });

  DateTime get localDate => dt.toLocal();
  bool get isNewMonth => localDate.day == 1;

  static Future<WeatherForecast?> fromOpenWeatherAPI({
    required DateTime dateTime,
    required String docId,
  }) async {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'];
    if (apiKey == null) {
      throw Exception('OpenWeather API key not found in environment variables');
    }
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Error user not logged in");
    }
    final temperatureLocationDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final GeoPoint location =
        temperatureLocationDoc.get("temperature_location");

    final lat = location.latitude;
    final lon = location.longitude;

    final dateUtc = dateTime.toUtc().millisecondsSinceEpoch ~/ 1000;
    final url =
        Uri.parse('https://api.openweathermap.org/data/3.0/onecall/timemachine'
            '?lat=$lat'
            '&lon=$lon'
            '&dt=$dateUtc'
            '&appid=$apiKey'
            '&units=metric');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherForecast._fromAPIResponse(json, docId);
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  // Private constructor for API response
  factory WeatherForecast._fromAPIResponse(
      Map<String, dynamic> json, String docId) {
    final data = json['data'][0] as Map<String, dynamic>;
    final weather = data['weather'][0] as Map<String, dynamic>;

    return WeatherForecast(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
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
      backgroundColor: null,
    );
  }

  factory WeatherForecast.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime dt;
    try {
      dt = (data['dt'] as Timestamp).toDate();
    } catch (e) {
      dt = DateTime.fromMillisecondsSinceEpoch((data['dt'] as int) * 1000);
    }

    final weahter_data = WeatherForecast(
      lat: (data['lat'] as num).toDouble(),
      lon: (data['lon'] as num).toDouble(),
      timezone: data['timezone'] as String,
      timezoneOffset: data['timezone_offset'] as int,
      docId: doc.id,
      dt: dt,
      temp: (data['temp'] as num).toInt(),
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
      backgroundColor: data['background_color'] is int
          ? Color(data['background_color'] as int)
          : null,
    );

    return weahter_data;
  }

  Map<String, dynamic> toFirestore() => {
        'lat': lat,
        'lon': lon,
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
        'background_color': backgroundColor?.toARGB32(),
      };

  factory WeatherForecast.fromTemperatureEntry(TemperatureEntry entry) {
    return WeatherForecast(
      lat: 59.9139,
      lon: 10.7522,
      timezone: 'Europe/Oslo',
      timezoneOffset: 3600,
      docId: entry.docId,
      dt: DateTime.fromMillisecondsSinceEpoch(
          entry.localDate.millisecondsSinceEpoch ~/ 1000),
      temp: entry.temperature.toInt(),
      feelsLike: entry.temperature.toDouble(),
      pressure: 0,
      humidity: 0,
      dewPoint: 0,
      uvi: 0,
      clouds: 0,
      visibility: 10000,
      windSpeed: 0,
      windDeg: 0,
      windGust: 0,
      sunrise: 0,
      sunset: 0,
      weatherId: 800,
      weatherMain: "Temperature",
      weatherDescription: "${entry.temperature}°C",
      weatherIcon: "01d",
      isKnitted: entry.isKnitted,
      knittingNote: entry.knittingNote,
      backgroundColor: entry.backgroundColor,
    );
  }

  @override
  String toString() {
    return 'WeatherForecast(docId: $docId, dt: ${dt.toIso8601String()}, temp: $temp°C, '
        'weather: $weatherMain ($weatherDescription), lat: $lat, lon: $lon, '
        'isKnitted: $isKnitted, knittingNote: $knittingNote), backgroundColor: $backgroundColor';
  }
}
