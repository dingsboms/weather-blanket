// Grid View for Edit Mode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tempestry/functions/color_provider.dart';
import 'package:tempestry/models/weather_data.dart';

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
    final Color currentColor = item.backgroundColor ??
        ref.watch(colorForTemperatureProvider(item.temp));
    return Column(
      children: [
        Container(
          height: itemHeight * 0.99,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                currentColor.withValues(alpha: 0.9),
                currentColor,
                currentColor.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
        if (item.isNewMonth)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                CupertinoColors.white.withValues(alpha: 0.9),
                CupertinoColors.white,
                CupertinoColors.white.withValues(alpha: 0.9),
              ]),
              borderRadius: BorderRadius.circular(10),
            ),
            height: itemHeight,
          ),
      ],
    );
  }
}
