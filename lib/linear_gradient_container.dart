import 'package:flutter/material.dart';

class TemperatureRangeSelector extends StatefulWidget {
  final double height;
  final double minTemp;
  final double maxTemp;
  final List<double> initialPositions;
  final Function(List<double>, List<Color>) onPositionsChanged;
  final bool editMode;

  const TemperatureRangeSelector({
    super.key,
    this.height = 40,
    this.minTemp = -20,
    this.maxTemp = 30,
    required this.initialPositions,
    required this.onPositionsChanged,
    this.editMode = false,
  });

  @override
  State<TemperatureRangeSelector> createState() =>
      _TemperatureRangeSelectorState();
}

class _TemperatureRangeSelectorState extends State<TemperatureRangeSelector> {
  late List<double> positions;
  int? dragIndex;
  double? dragStartX;
  double? initialDragPosition;

  final List<Color> gradientColors = const [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Color.fromARGB(255, 121, 1, 1)
  ];

  @override
  void initState() {
    super.initState();
    positions = List.from(widget.initialPositions);
  }

  Color getColorAtPosition(double position) {
    if (position <= 0) return gradientColors.first;
    if (position >= 1) return gradientColors.last;

    double segmentLength = 1 / (gradientColors.length - 1);
    int index = (position / segmentLength).floor();
    if (index >= gradientColors.length - 1) return gradientColors.last;

    double localPosition = (position - index * segmentLength) / segmentLength;
    return Color.lerp(
        gradientColors[index], gradientColors[index + 1], localPosition)!;
  }

  void _startDrag(int index, DragStartDetails details) {
    if (!widget.editMode) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final position = box.globalToLocal(details.globalPosition);
    dragStartX = position.dx;
    dragIndex = index;
    initialDragPosition = positions[index];
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!mounted ||
        dragIndex == null ||
        dragStartX == null ||
        initialDragPosition == null) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final double delta =
        box.globalToLocal(details.globalPosition).dx - dragStartX!;
    final double newPosition =
        (initialDragPosition! + delta / box.size.width).clamp(0.0, 1.0);

    if (mounted) {
      setState(() {
        positions[dragIndex!] = newPosition;
        positions.sort();
        dragIndex = positions.indexOf(newPosition);
        _notifyChange();
      });
    }
  }

  void _endDrag(DragEndDetails details) {
    dragStartX = null;
    dragIndex = null;
    initialDragPosition = null;
  }

  void _notifyChange() {
    if (!mounted) return;
    final colors = positions.map((pos) => getColorAtPosition(pos)).toList();
    widget.onPositionsChanged(List.from(positions), colors);
  }

  String _getIntervalLabel(int index) {
    double temp =
        widget.minTemp + (widget.maxTemp - widget.minTemp) * positions[index];
    if (index == 0) {
      return '< ${temp.toStringAsFixed(1)}°';
    } else if (index == positions.length - 1) {
      return '${temp.toStringAsFixed(1)}° <';
    } else {
      double prevTemp = widget.minTemp +
          (widget.maxTemp - widget.minTemp) * positions[index - 1];
      return '${prevTemp.toStringAsFixed(1)}° - ${temp.toStringAsFixed(1)}°';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + 40,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            height: widget.height,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
              ),
            ),
          ),
          for (int i = 0; i < positions.length; i++)
            Positioned(
              left: positions[i] * MediaQuery.of(context).size.width - 10,
              child: GestureDetector(
                onHorizontalDragStart: (details) => _startDrag(i, details),
                onHorizontalDragUpdate: _updateDrag,
                onHorizontalDragEnd: _endDrag,
                onDoubleTap: widget.editMode && positions.length > 2
                    ? () {
                        if (mounted) {
                          setState(() {
                            positions.removeAt(i);
                            _notifyChange();
                          });
                        }
                      }
                    : null,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getIntervalLabel(i),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ),
                    if (widget.editMode)
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                dragIndex == i ? Colors.blue : Colors.black26,
                            width: dragIndex == i ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.drag_handle, size: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
