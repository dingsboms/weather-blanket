import 'package:flutter/cupertino.dart';
import 'package:tempestry/components/color/color_segments/functions/update_colors.dart';
import 'package:tempestry/pages/configure_new_user.dart/components/temperature_multi_slider.dart';
import 'package:tempestry/models/range_interval.dart';
import 'package:tempestry/functions/color_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseDateRangePage extends ConsumerStatefulWidget {
  const ChooseDateRangePage({super.key, required this.onDateRangeSelected});
  final VoidCallback onDateRangeSelected;

  @override
  ConsumerState<ChooseDateRangePage> createState() =>
      _ChooseDateRangePageState();
}

class _ChooseDateRangePageState extends ConsumerState<ChooseDateRangePage> {
  // Local editable copy while user adjusts sliders
  List<RangeInterval> _pendingIntervals = [];
  bool _intervalsLoaded =
      false; // becomes true once first data arrives or user edits

  @override
  Widget build(BuildContext context) {
    final asyncIntervals = ref.watch(colorRangesProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Choose a date range for your temperatures"),
          // Use AsyncValue.when to build different UIs for loading/error/data
          asyncIntervals.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CupertinoActivityIndicator(),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Error loading intervals: $e'),
            ),
            data: (fetched) {
              // If we haven't modified locally yet, show fetched data
              final intervals = _intervalsLoaded && _pendingIntervals.isNotEmpty
                  ? _pendingIntervals
                  : fetched;
              return TemperatureMultiSlider(
                initialRangeColors: intervals,
                onIntervalsChanged: (list) {
                  setState(() {
                    _pendingIntervals = list;
                    _intervalsLoaded = true;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: _intervalsLoaded && _pendingIntervals.isNotEmpty
                ? () async {
                    await updateColors(_pendingIntervals, ref);

                    widget.onDateRangeSelected();
                  }
                : null,
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}
