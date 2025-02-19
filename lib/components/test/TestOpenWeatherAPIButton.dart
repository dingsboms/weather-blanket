import 'package:flutter/cupertino.dart';
import 'package:weather_blanket/models/weather_data.dart';

class TestOpenWeatherAPIButton extends StatelessWidget {
  const TestOpenWeatherAPIButton({super.key});

  Future<void> _testAPI(BuildContext context) async {
    try {
      // Show loading indicator
      showCupertinoDialog(
        context: context,
        builder: (context) => const Center(child: CupertinoActivityIndicator()),
        barrierDismissible: false,
      );

      // Get today's date at noon
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 12);

      // Generate a document ID
      const docId = "docID";

      // Fetch weather data
      final forecast = await WeatherForecast.fromOpenWeatherAPI(
        dateTime: today,
        docId: docId,
      );

      // Hide loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (forecast != null && context.mounted) {
        // Show data dialog
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Weather Data'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Temperature: ${forecast.temp}°C'),
                  Text('Feels like: ${forecast.feelsLike}°C'),
                  Text('Weather: ${forecast.weatherDescription}'),
                  Text('Humidity: ${forecast.humidity}%'),
                  Text('Wind Speed: ${forecast.windSpeed} m/s'),
                  Text('Wind Direction: ${forecast.windDeg}°'),
                  Text('Cloud Cover: ${forecast.clouds}%'),
                  Text('UV Index: ${forecast.uvi}'),
                  Text('Visibility: ${forecast.visibility}m'),
                  Text('Time: ${forecast.localDate.toString()}'),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 20,
                    color: forecast.backgroundColor,
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else if (context.mounted) {
        // Show error dialog
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to fetch weather data'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator if visible
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error dialog
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Error: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton.filled(
        onPressed: () => _testAPI(context),
        child: const Text('Test OpenWeather API'),
      ),
    );
  }
}
