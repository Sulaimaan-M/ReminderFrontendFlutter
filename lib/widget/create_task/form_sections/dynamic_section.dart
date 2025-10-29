import 'package:flutter/material.dart';
import '../../../model/interval_type.dart';
import '../inline_date_picker.dart';
import '../weekly_multi_selector.dart';
import '../monthly_selector.dart';
import '../inline_yearly_picker.dart';
import '../../../model/yearly_selection.dart';

class DynamicSection extends StatelessWidget {
  final IntervalType repetition;

  // Simple mode
  final DateTime simpleDate;
  final ValueChanged<DateTime> onDateChanged;

  // Weekly mode
  final List<int> selectedDays;
  final ValueChanged<List<int>> onDaysChanged;

  // Monthly mode
  final MonthlyMode monthlyMode;
  final int monthlySingleDay;
  final int monthlyRangeStart;
  final int monthlyRangeEnd;
  final ValueChanged<MonthlyMode> onMonthlyModeChanged;
  final ValueChanged<int> onMonthlySingleDayChanged;
  final ValueChanged<int> onMonthlyRangeStartChanged;
  final ValueChanged<int> onMonthlyRangeEndChanged;

  // Yearly mode
  final YearlySelection yearlySelection;
  final ValueChanged<YearlySelection> onYearlySelectionChanged;

  const DynamicSection({
    super.key,
    required this.repetition,
    required this.simpleDate,
    required this.selectedDays,
    required this.onDateChanged,
    required this.onDaysChanged,
    required this.monthlyMode,
    required this.monthlySingleDay,
    required this.monthlyRangeStart,
    required this.monthlyRangeEnd,
    required this.onMonthlyModeChanged,
    required this.onMonthlySingleDayChanged,
    required this.onMonthlyRangeStartChanged,
    required this.onMonthlyRangeEndChanged,
    required this.yearlySelection,
    required this.onYearlySelectionChanged,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Schedule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            MonthlySelector(
              mode: monthlyMode,
              singleDay: monthlySingleDay,
              rangeStart: monthlyRangeStart,
              rangeEnd: monthlyRangeEnd,
              onModeChanged: onMonthlyModeChanged,
              onSingleDayChanged: onMonthlySingleDayChanged,
              onRangeStartChanged: onMonthlyRangeStartChanged,
              onRangeEndChanged: onMonthlyRangeEndChanged,
            ),
          ],
        );

      case IntervalType.yearly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date (Month & Day)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InlineYearlyPicker(
              selection: yearlySelection,
              onSelectionChanged: onYearlySelectionChanged,
            ),
          ],
        );

      case IntervalType.daily:
      default:
        return const SizedBox.shrink();
    }
  }
}