import 'package:flutter/material.dart';
import '../../../model/interval_type.dart';
import '../inline_date_picker.dart';
import '../weekly_multi_selector.dart';
import '../monthly_selector.dart';
import '../inline_yearly_picker.dart';
import '../../../model/yearly_selection.dart';

class DynamicSection extends StatelessWidget {
  final IntervalType repetition;
  final DateTime simpleDate;
  final List<int> selectedDays;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<List<int>> onDaysChanged;

  const DynamicSection({
    super.key,
    required this.repetition,
    required this.simpleDate,
    required this.selectedDays,
    required this.onDateChanged,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (repetition) {
      case IntervalType.simple:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InlineDatePicker(
              date: simpleDate,
              onDateChanged: onDateChanged,
            ),
          ],
        );
      case IntervalType.weekly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Days of Week',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            WeeklyMultiSelector(
              selectedDays: selectedDays,
              onDaysChanged: onDaysChanged,
            ),
          ],
        );
      case IntervalType.monthly:
      // You'll need to add the monthly selector state management
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Schedule',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            // Add MonthlySelector here with proper state
            Text('Monthly selector needs state management'),
          ],
        );
      case IntervalType.yearly:
      // You'll need to add the yearly selector state management
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date (Month & Day)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            // Add InlineYearlyPicker here with proper state
            Text('Yearly picker needs state management'),
          ],
        );
      case IntervalType.daily:
      default:
        return const SizedBox.shrink();
    }
  }
}