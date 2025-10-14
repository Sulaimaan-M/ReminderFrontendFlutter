// widget/create_reminder/repetition_selector.dart

import 'package:flutter/material.dart';
import '../../model/reminder.dart'; // for IntervalType

class RepetitionSelector extends StatelessWidget {
  final IntervalType value;
  final ValueChanged<IntervalType> onChanged;

  const RepetitionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IntervalType>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Repeat',
        border: OutlineInputBorder(),
      ),
      items: IntervalType.values.map((e) {
        return DropdownMenuItem(value: e, child: Text(e.label));
      }).toList(),
      onChanged: (value) => onChanged(value!),
    );
  }
}