import 'package:tempestry/pages/configure_new_user.dart/components/range_interval_color_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_slider/flutter_multi_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tempestry/components/color/color_segments/functions/delete_range_interval.dart';
import 'package:tempestry/components/color/interval_color_picker_dialog.dart';
import 'package:tempestry/models/range_interval.dart';

class TemperatureMultiSlider extends ConsumerStatefulWidget {
  const TemperatureMultiSlider(
      {super.key,
      required this.initialRangeColors,
      required this.onIntervalsChanged});

  final List<RangeInterval> initialRangeColors;
  final void Function(List<RangeInterval> intervals) onIntervalsChanged;

  @override
  ConsumerState<TemperatureMultiSlider> createState() =>
      _TemperatureMultiSliderState();
}

class _TemperatureMultiSliderState
    extends ConsumerState<TemperatureMultiSlider> {
  late List<RangeInterval> _rangeIntervalColors;
  late List<Color> _rangeColors;
  late List<double> _rangeThumbs;
  late int _computedDivisions;
  late int _sliderMin; // actual slider bounds (may include padding)
  late int _sliderMax;
  static const double _thumbRadius = 8; // keep in sync with thumbBuilder
  static const double _boxHalfSize = 20; // 40px box
  static const double _boxCenterAdjust =
      0.0; // tweak if a tiny pixel shift is needed
  static const double _sliderTop = 50; // y-position where MultiSlider is placed
  static const double _addButtonsOffsetFromSlider =
      6; // distance above slider track
  // No hover add buttons now

  void _updateSliderBounds() {
    if (_rangeThumbs.isNotEmpty) {
      _sliderMin = _rangeThumbs.first.round() - 5;
      _sliderMax = _rangeThumbs.last.round() + 5;
      if (_sliderMin >= _sliderMax) {
        _sliderMax = _sliderMin + 10; // ensure positive span
      }
    } else {
      // Single interval (no internal boundaries)
      final only = _rangeIntervalColors.first;
      _sliderMin = only.minTemp - 5;
      _sliderMax = only.maxTemp + 5;
    }
    _computedDivisions = (_sliderMax - _sliderMin).abs();
    if (_computedDivisions == 0) _computedDivisions = 1;
  }

  // Add interval at start or end only (static buttons)

  Future<void> _addInterval({required bool atStart}) async {
    if (_rangeIntervalColors.isEmpty) return;
    final refInterval =
        atStart ? _rangeIntervalColors.first : _rangeIntervalColors.last;
    final newMin = atStart ? refInterval.minTemp - 4 : refInterval.maxTemp + 1;
    final newMax = atStart ? refInterval.minTemp - 1 : refInterval.maxTemp + 4;
    final newInterval = RangeInterval(
      minTemp: newMin,
      maxTemp: newMax,
      color: CupertinoColors.inactiveGray,
    );

    setState(() {
      if (atStart) {
        _rangeIntervalColors.insert(0, newInterval);
      } else {
        _rangeIntervalColors.add(newInterval);
      }
      _rebuildFromIntervals();
    });

    // Prompt user to pick color for new interval
    final idx = atStart ? 0 : _rangeIntervalColors.length - 1;
    await _pickColorForInterval(idx);
    widget.onIntervalsChanged(_rangeIntervalColors);
  }

  void _addIntervalAtStart() => _addInterval(atStart: true);
  void _addIntervalAtEnd() => _addInterval(atStart: false);

  void _rebuildFromIntervals() {
    _rangeIntervalColors.sort((a, b) => a.minTemp.compareTo(b.minTemp));
    _rangeColors = _rangeIntervalColors.map((ri) => ri.color).toList();
    if (_rangeIntervalColors.length <= 1) {
      _rangeThumbs = <double>[];
    } else {
      _rangeThumbs = _rangeIntervalColors
          .take(_rangeIntervalColors.length - 1)
          .map((ri) => ri.maxTemp.toDouble())
          .toList(growable: true);
    }
    _updateSliderBounds();
  }

  // Removed splitting functionality.

  @override
  void initState() {
    super.initState();
    _rangeIntervalColors = List.from(widget.initialRangeColors);
    // Ensure intervals are sorted by minTemp ascending.
    _rangeIntervalColors.sort((a, b) => a.minTemp.compareTo(b.minTemp));
    _rangeColors = _rangeIntervalColors.map((ri) => ri.color).toList();
    // We want one thumb per touching interval boundary (i.e. between adjacent intervals),
    // not one thumb per interval. For N intervals there are N-1 internal boundaries.
    // A boundary is represented by the maxTemp of the left interval (equivalently minTemp - 1 of the right).
    if (_rangeIntervalColors.length <= 1) {
      _rangeThumbs = <double>[]; // No internal boundaries.
    } else {
      _rangeThumbs = _rangeIntervalColors
          .take(_rangeIntervalColors.length - 1)
          .map((ri) => ri.maxTemp.toDouble())
          .toList(growable: true);
    }
    _updateSliderBounds();
  }

  // ---- Thumb constraint helpers -------------------------------------------------

  /// Whether any adjacent pair violates the minimum gap constraint.
  bool _hasMinGapViolation(List<double> values, double minGap) {
    for (var i = 1; i < values.length; i++) {
      if (values[i] - values[i - 1] < minGap) return true;
    }
    return false;
  }

  // Converts a pixel position (relative to slider width) to a value using same formula as package.
  double _valueToPixel(double value, double totalWidth,
      {double? minOverride, double? maxOverride}) {
    final thumbDiameter = _thumbRadius * 2;
    final usable = totalWidth - thumbDiameter;
    final minVal = minOverride ?? _sliderMin.toDouble();
    final maxVal = maxOverride ?? _sliderMax.toDouble();
    final span = (maxVal - minVal).abs();
    if (span <= 0) return totalWidth / 2;
    final t = (value - minVal) / span;
    return _thumbRadius + t * usable;
  }

  // Find interval index that contains value v. Returns 0.._values.length
  Future<void> _pickColorForInterval(int intervalIndex) async {
    final interval = _rangeIntervalColors[intervalIndex];
    final label = '${interval.minTemp}° to ${interval.maxTemp}°';
    final rangeIntervalColor = _rangeIntervalColors[intervalIndex];
    final pickedColor = await showDialog<Color?>(
      context: context,
      builder: (ctx) => IntervalColorPickerDialog(
        initialColor: rangeIntervalColor.color,
        intervalLabel: label,
        onSubmit: (color) {
          Navigator.of(ctx).pop(color);
        },
        onDelete: () async {
          final updated =
              await deleteRangeIntervalFromFirestore(rangeIntervalColor, ref);
          if (!mounted) return;
          setState(() {
            _rangeIntervalColors = List<RangeInterval>.from(updated);
            _rangeColors = _rangeIntervalColors.map((ri) => ri.color).toList();
            _rangeThumbs = _rangeIntervalColors.length <= 1
                ? <double>[]
                : _rangeIntervalColors
                    .take(_rangeIntervalColors.length - 1)
                    .map((ri) => ri.maxTemp.toDouble())
                    .toList(growable: true);
            _updateSliderBounds();
          });
          widget.onIntervalsChanged(_rangeIntervalColors);
          GoRouter.of(ctx).pop(); // Correct dialog closure
        },
      ),
    );
    if (mounted) {
      setState(() {
        if (pickedColor != null) {
          _rangeIntervalColors[intervalIndex] =
              _rangeIntervalColors[intervalIndex].copyWith(color: pickedColor);
        }
        _rebuildFromIntervals();
      });
      widget.onIntervalsChanged(_rangeIntervalColors);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final sliderWidth = constraints.maxWidth;

      final thumbPixels = [
        for (final v in _rangeThumbs) _valueToPixel(v, sliderWidth)
      ];
      final startPixel = _valueToPixel(_sliderMin.toDouble(), sliderWidth);
      final endPixel = _valueToPixel(_sliderMax.toDouble(), sliderWidth);
      final boundaries = [startPixel, ...thumbPixels, endPixel];
      final List<_IntervalButtonData> buttons = [
        for (int i = 0; i < boundaries.length - 1; i++)
          _IntervalButtonData(
              index: i,
              pixelX: (boundaries[i] + boundaries[i + 1]) / 2,
              color: _rangeIntervalColors[i].color)
      ];

      return SizedBox(
        height: 110, // space for buttons + slider
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Compute vertical position for add buttons: midpoint between box row (height 40) and slider top
            // Boxes start at 0 with height = _boxHalfSize*2.
            // Slider starts at _sliderTop. Place add buttons centered between.
            Positioned.fill(
                child:
                    SizedBox()), // placeholder to allow using variables below
            // Color picker buttons (above slider)
            for (final b in buttons)
              Positioned(
                top: 0,
                left: b.pixelX - _boxHalfSize + _boxCenterAdjust,
                child: RangeIntervalColorBox(
                  interval: _rangeIntervalColors[b.index],
                  size: _boxHalfSize * 2,
                  onColorPicked: (color) {
                    setState(() {
                      _rangeIntervalColors[b.index] =
                          _rangeIntervalColors[b.index].copyWith(color: color);
                      _rebuildFromIntervals();
                    });
                    widget.onIntervalsChanged(_rangeIntervalColors);
                  },
                  onDelete: () {}, // Provide a default no-op for onDelete
                ),
              ),
            // Static add buttons positioned between color boxes and slider
            Builder(builder: (ctx) {
              const double addSize = 32;
              final double boxesBottom = _boxHalfSize * 2;
              final double centerBandTop = boxesBottom;
              // centerBandBottom no longer needed (we anchor to sliderTop)
              // Place buttons relative to slider (just above it), overriding previous midpoint logic.
              double addTop =
                  _sliderTop - addSize - _addButtonsOffsetFromSlider;
              if (addTop < centerBandTop) {
                // Ensure still below the color boxes row
                addTop = centerBandTop;
              }
              return Stack(children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: _sliderTop,
                  child: MultiSlider(
                    // One value per internal boundary. (Intervals count = values.length + 1)
                    values: _rangeThumbs,
                    min: _sliderMin.toDouble(),
                    max: _sliderMax.toDouble(),
                    divisions: _computedDivisions,
                    rangeColors: _rangeColors,
                    onChanged: (List<double> newValues) {
                      const double minGap = 1.0;
                      if (_hasMinGapViolation(newValues, minGap)) return;
                      setState(() {
                        _rangeThumbs = List<double>.from(newValues)..sort();
                        for (int i = 0; i < _rangeThumbs.length; i++) {
                          final boundary = _rangeThumbs[i].round();
                          final left = _rangeIntervalColors[i];
                          final right = _rangeIntervalColors[i + 1];
                          _rangeIntervalColors[i] =
                              left.copyWith(maxTemp: boundary);
                          _rangeIntervalColors[i + 1] =
                              right.copyWith(minTemp: boundary + 1);
                        }
                        for (final ri in _rangeIntervalColors) {
                          ri.setInt();
                        }
                        _updateSliderBounds();
                      });
                    },
                    onChangeEnd: (value) =>
                        widget.onIntervalsChanged(_rangeIntervalColors),
                    thumbBuilder: (v) => const ThumbOptions(
                      color: CupertinoColors.activeBlue,
                      radius: _thumbRadius,
                    ),
                    trackbarBuilder: (r) =>
                        const TrackbarOptions(isActive: true),
                  ),
                ),
                Positioned(
                  top: addTop,
                  left: 0,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: addSize,
                    onPressed: _addIntervalAtStart,
                    child: const Icon(CupertinoIcons.add_circled, size: 26),
                  ),
                ),
                Positioned(
                  top: addTop,
                  right: 0,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: addSize,
                    onPressed: _addIntervalAtEnd,
                    child: const Icon(CupertinoIcons.add_circled, size: 26),
                  ),
                ),
              ]);
            }),
          ],
        ),
      );
    });
  }
}

class _IntervalButtonData {
  final int index;
  final double pixelX;
  final Color color;
  _IntervalButtonData(
      {required this.index, required this.pixelX, required this.color});
}

// _GapHoverRegion removed; replaced by _ThumbGapHoverRegion logic targeting actual slider thumbs.

// Removed hover gap add button widget.
