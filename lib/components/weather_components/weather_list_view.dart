import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tempestry/components/weather_components/weather_list_item.dart';
import 'package:tempestry/models/weather_data.dart';

class WeatherListView extends StatefulWidget {
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
  State<WeatherListView> createState() => _WeatherListViewState();
}

class _WeatherListViewState extends State<WeatherListView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => WeatherListItem(
              userId: widget.userId,
              item: widget.items[index],
              ref: widget.ref,
            ),
            childCount: widget.items.length,
          ),
        ),
      ],
    );
  }
}
