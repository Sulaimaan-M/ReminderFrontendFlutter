// widget/create_reminder_screen/repetition_selector.dart

import 'package:flutter/material.dart';

// Make sure Repetition enum is defined HERE (or imported)
enum Repetition {
  simple, daily, weekly, monthly, yearly;

  String get label {
    switch (this) {
      case simple: return 'Simple';
      case daily: return 'Daily';
      case weekly: return 'Weekly';
      case monthly: return 'Monthly';
      case yearly: return 'Yearly';
    }
  }

  String toIntervalType() => name.toUpperCase();
}

class RepetitionSelector extends StatelessWidget {
  final Repetition? value; // ← nullable
  final ValueChanged<Repetition?> onChanged;

  const RepetitionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Repetition>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Repeat',
        border: OutlineInputBorder(),
      ),
      items: Repetition.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
      onChanged: onChanged, // ← passes Repetition?
    );
  }
}