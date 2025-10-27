import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../model/yearly_selection.dart';

class InlineYearlyPicker extends StatelessWidget {
  final YearlySelection selection;
  final ValueChanged<YearlySelection> onSelectionChanged;

  const InlineYearlyPicker({
    super.key,
    required this.selection,
    required this.onSelectionChanged,
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
              scrollController: FixedExtentScrollController(initialItem: selection.month - 1),
              onSelectedItemChanged: (index) {
                onSelectionChanged(YearlySelection(index + 1, selection.day));
              },
              children: months.map((m) => Center(child: Text(m, style: const TextStyle(fontSize: 16)))).toList(),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 32,
              scrollController: FixedExtentScrollController(initialItem: selection.day - 1),
              onSelectedItemChanged: (index) {
                onSelectionChanged(YearlySelection(selection.month, index + 1));
              },
              children: List.generate(31, (i) => Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 16)))),
            ),
          ),
        ],
      ),
    );
  }
}