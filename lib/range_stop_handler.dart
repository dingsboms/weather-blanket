// lib/range_stop_handler.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RangeStop {
  final double position;
  final double temperature;
  final Color color;

  RangeStop({
    required this.position,
    required this.temperature,
    required this.color,
  });
}

class RangeStopHandle extends StatelessWidget {
  final String intervalLabel;
  final Color color;
  final bool editMode;

  const RangeStopHandle({
    super.key,
    required this.intervalLabel,
    required this.color,
    required this.editMode,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            intervalLabel,
            style: const TextStyle(fontSize: 10, color: CupertinoColors.black),
          ),
        ),
        if (editMode) // Only show handle in edit mode
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: CupertinoColors.black),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.2),
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
    );
  }
}
