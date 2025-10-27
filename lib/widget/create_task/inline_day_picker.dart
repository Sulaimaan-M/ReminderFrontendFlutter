import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InlineDayPicker extends StatelessWidget {
  final int day;
  final ValueChanged<int> onDayChanged;

  const InlineDayPicker({
    super.key,
    required this.day,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      itemExtent: 28,
      scrollController: FixedExtentScrollController(initialItem: day - 1),
      onSelectedItemChanged: (index) => onDayChanged(index + 1),
      children: List.generate(
        31,
            (i) => Center(
          child: Text(
            '${i + 1}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}