import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:tempestry/components/color/color_box.dart';
import 'package:tempestry/components/color/color_segments/color_segments.dart';
import 'package:tempestry/models/weather_data.dart';

class ColorSegmentsListTile extends StatefulWidget {
  const ColorSegmentsListTile(
      {super.key, required this.weatherItem, required this.onSegmentPicked});
  final WeatherForecast weatherItem;
  final Function(Color pickedColor) onSegmentPicked;

  @override
  State<ColorSegmentsListTile> createState() => _ColorSegmentsListTileState();
}

class _ColorSegmentsListTileState extends State<ColorSegmentsListTile> {
  @override
  Widget build(BuildContext context) {
    return ColorSegments(segmentBuilder:
        (context, interval, onUpdate, onDelete, intervalsOverlap) {
      return GestureDetector(
          onTap: () async {
            widget.weatherItem.temp = interval.minTemp;
            await widget.weatherItem.updateFirestoreUserDoc();
            widget.onSegmentPicked(interval.color);
            if (context.mounted) {
              context.pop();
            }
          },
          child: ColorBox(currentColor: interval.color));
    });
  }
}
