import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/models/weather_data.dart';

class WeatherItemScreen extends StatelessWidget {
  const WeatherItemScreen({super.key, required this.item, required this.ref});
  final WeatherForecast item;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(item.dt.toString()),
      content: SizedBox(
        width: 100,
        height: 100,
        child: Container(
          decoration: BoxDecoration(
              color: ref.watch(colorForTemperatureProvider(item.temp))),
        ),
      ),
    );
  }
}
