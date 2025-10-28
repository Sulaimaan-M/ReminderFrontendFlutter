import 'package:flutter/material.dart';
import '../../../model/interval_type.dart';

class RepetitionSection extends StatelessWidget {
  final IntervalType value;
  final ValueChanged<IntervalType> onChanged;

  const RepetitionSection({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<IntervalType>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
          ),
          items: IntervalType.values.map((e) {
            return DropdownMenuItem(value: e, child: Text(e.label));
          }).toList(),
          onChanged: (value) => onChanged(value!),
        ),
      ],
    );
  }
}// TODO Implement this library.