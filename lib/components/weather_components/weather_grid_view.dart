// Grid View for Edit Mode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/functions/color_provider.dart';
import 'package:weather_blanket/models/weather_data.dart';

class WeatherGridView extends StatelessWidget {
  final List<WeatherForecast> items;
  final WidgetRef ref;

  const WeatherGridView({super.key, required this.items, required this.ref});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final numberOfMonthBreaks =
            items.where((item) => item.isNewMonth).length;
        final double itemHeight =
            constraints.maxHeight / (items.length + numberOfMonthBreaks);

        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildGridItem(items[index], itemHeight),
                childCount: items.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridItem(WeatherForecast item, double itemHeight) {
    return Column(
      children: [
        Container(
          height: itemHeight * 0.99,
          color: ref.watch(colorForTemperatureProvider(item.temp)),
        ),
        Container(
          height: itemHeight * 0.01,
          color: CupertinoColors.white.withValues(alpha: 0.3),
        ),
        if (item.isNewMonth)
          Divider(
            color: CupertinoColors.white,
            thickness: itemHeight,
            height: itemHeight,
          ),
      ],
    );
  }
}
