import 'package:flutter/material.dart';

class WeeklySection extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onDaySelected;

  const WeeklySection({
    super.key,
    required this.selected,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repeat on:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(weekdays.length, (i) {
            return ChoiceChip(
              label: Text(weekdays[i]),
              selected: selected == i,
              onSelected: (selected) => onDaySelected(selected ? i : this.selected),
            );
          }),
        ),
      ],
    );
  }
}