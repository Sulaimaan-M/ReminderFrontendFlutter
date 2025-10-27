import 'package:flutter/material.dart';

class WeeklyMultiSelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onDaysChanged;

  const WeeklyMultiSelector({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select one or more days',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(weekdays.length, (i) {
            final isSelected = selectedDays.contains(i);
            return FilterChip(
              label: Text(weekdays[i]),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = List<int>.from(selectedDays);
                if (selected) {
                  newSelection.add(i);
                } else {
                  newSelection.remove(i);
                }
                newSelection.sort();
                onDaysChanged(newSelection);
              },
            );
          }),
        ),
        if (selectedDays.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select at least one day',
              style: TextStyle(fontSize: 12, color: Colors.red[700]),
            ),
          ),
      ],
    );
  }
}