import 'package:flutter/cupertino.dart';

class MigrateOsloMetToOpenWeatherButton extends StatelessWidget {
  const MigrateOsloMetToOpenWeatherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () => migrateToOpenWeather(),
      child: const Text("Migrate Oslo Met Data to Open Weather"),
    );
  }
}

migrateToOpenWeather() {}
