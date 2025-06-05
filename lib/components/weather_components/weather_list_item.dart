import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/knitting_checkbox.dart';
import 'package:weather_blanket/components/note_button.dart';
import 'package:weather_blanket/components/weather_components/weather_item_screen.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/models/weather_data.dart';

class WeatherListItem extends StatelessWidget {
  final String userId;
  final WeatherForecast item;
  final WidgetRef ref;

  const WeatherListItem({
    super.key,
    required this.userId,
    required this.item,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    Color currentColor = ref.watch(colorForTemperatureProvider(item.temp));
    return GestureDetector(
      onLongPress: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return WeatherItemScreen(
              item: item,
              ref: ref,
            );
          }),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  currentColor,
                  Color.lerp(currentColor, Colors.white, 0.15)!,
                  currentColor,
                ],
              ),
              border: const Border(bottom: BorderSide()),
            ),
            child: CupertinoListTile(
              leadingSize: 90,
              title: Text('${item.temp.round()} °C'),
              leading: Text(
                '${item.localDate.day}/${item.localDate.month}-${item.localDate.year}',
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                '${item.localDate.hour.toString().padLeft(2, "0")}:${item.localDate.minute.toString().padLeft(2, "0")}',
              ),
              additionalInfo: NoteButton(userId: userId, item: item),
              trailing: KnittingCheckbox(userId: userId, item: item),
            ),
          ),
          if (item.isNewMonth)
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        CupertinoColors.white.withValues(alpha: 0.7),
                        CupertinoColors.white,
                        CupertinoColors.white.withValues(alpha: 0.7),
                      ])),
              height: 10,
            )
        ],
      ),
    );
  }

  BorderSide customBorderSide(BuildContext context) =>
      BorderSide(color: CupertinoColors.separator.resolveFrom(context));
}
