import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tempestry/components/color/color_segments/functions/update_colors.dart';
import 'package:tempestry/components/color/get_default_colors.dart';
import 'package:tempestry/functions/color_provider.dart';
import 'package:tempestry/models/range_interval.dart';
import 'package:tempestry/pages/configure_new_user.dart/components/temperature_multi_slider.dart';

/// Wrapper that fetches the user's saved temperature color intervals
/// and plugs them into [TemperatureMultiSlider], persisting any changes.
class UserTemperatureMultiSlider extends ConsumerStatefulWidget {
  const UserTemperatureMultiSlider({super.key});

  @override
  ConsumerState<UserTemperatureMultiSlider> createState() =>
      _UserTemperatureMultiSliderState();
}

class _UserTemperatureMultiSliderState
    extends ConsumerState<UserTemperatureMultiSlider> {
  bool _fetchingDefaults = false; // prevent duplicate default fetches

  Future<void> _storeDefaultsIfNeeded() async {
    if (_fetchingDefaults) return;
    _fetchingDefaults = true;
    final defaults = await getDefaultColors();
    if (mounted && defaults.isNotEmpty) {
      await updateColors(defaults, ref); // persists + invalidates provider
    }
    _fetchingDefaults = false;
  }

  Future<void> _handleIntervalsChanged(List<RangeInterval> updated) async {
    await updateColors(
        updated, ref); // updateColors already invalidates provider
  }

  @override
  Widget build(BuildContext context) {
    final asyncRanges = ref.watch(colorRangesProvider);

    return asyncRanges.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (err, st) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Failed to load colors'),
          const SizedBox(height: 8),
          CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            onPressed: () => ref.refresh(colorRangesProvider),
            child: const Text('Retry'),
          )
        ],
      ),
      data: (ranges) {
        if (ranges.isEmpty) {
          // Kick off default fetch & show progress
          _storeDefaultsIfNeeded();
          return const Center(child: CupertinoActivityIndicator());
        }
        // Key ensures the internal state of TemperatureMultiSlider resets when list shape changes.
        final sliderKey = ValueKey(
          ranges
              .map((r) => '${r.minTemp}-${r.maxTemp}-${r.color.value}')
              .join('|'),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TemperatureMultiSlider(
              key: sliderKey,
              initialRangeColors: ranges,
              onIntervalsChanged: _handleIntervalsChanged,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
