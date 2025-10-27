import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InlineDatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  const InlineDatePicker({
    super.key,
    required this.date,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

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
            flex: 2,
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(initialItem: date.month - 1),
              onSelectedItemChanged: (index) {
                onDateChanged(DateTime(date.year, index + 1, date.day));
              },
              children: months.map((m) => Center(child: Text(m, style: const TextStyle(fontSize: 16)))).toList(),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(initialItem: date.day - 1),
              onSelectedItemChanged: (index) {
                onDateChanged(DateTime(date.year, date.month, index + 1));
              },
              children: List.generate(31, (i) => Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 16)))),
            ),
          ),
          Expanded(
            flex: 2,
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(initialItem: date.year - 2025),
              onSelectedItemChanged: (index) {
                onDateChanged(DateTime(2025 + index, date.month, date.day));
              },
              children: List.generate(10, (i) => Center(child: Text('${2025 + i}', style: const TextStyle(fontSize: 16)))),
            ),
          ),
        ],
      ),
    );
  }
}