// List View for Normal Mode
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_blanket/components/weather_components/weather_list_item.dart';
import 'package:weather_blanket/models/weather_data.dart';

class WeatherListView extends StatelessWidget {
  final String userId;
  final List<WeatherForecast> items;
  final WidgetRef ref;

  const WeatherListView({
    super.key,
    required this.userId,
    required this.items,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => WeatherListItem(
              userId: userId,
              item: items[index],
              ref: ref,
            ),
            childCount: items.length,
          ),
        ),
      ],
    );
  }
}
