import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InlineTimePicker extends StatelessWidget {
  final int hour;
  final int minute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const InlineTimePicker({
    super.key,
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(initialItem: hour),
              onSelectedItemChanged: onHourChanged,
              children: List.generate(
                24,
                    (i) => Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(initialItem: minute),
              onSelectedItemChanged: onMinuteChanged,
              children: List.generate(
                60,
                    (i) => Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}