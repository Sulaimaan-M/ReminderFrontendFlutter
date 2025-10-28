import 'package:flutter/material.dart';
import '../inline_time_picker.dart';

class TimeSection extends StatelessWidget {
  final int hour;
  final int minute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  const TimeSection({
    super.key,
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InlineTimePicker(
          hour: hour,
          minute: minute,
          onHourChanged: onHourChanged,
          onMinuteChanged: onMinuteChanged,
        ),
      ],
    );
  }
}