// widget/create_reminder/dynamic_section.dart

import 'package:flutter/material.dart';
import '../../model/reminder.dart';
import 'simple_date_section.dart';
import 'weekly_section.dart';
import 'monthly_section.dart';
import 'yearly_section.dart';

class DynamicSection extends StatelessWidget {
  final IntervalType repetition;
  final DateTime simpleDate;
  final int selectedWeekday;
  final int monthlyDay;
  final YearlySelection yearlySelection;
  final ValueChanged<DateTime> onSimpleDateSelected;
  final ValueChanged<int> onWeekdaySelected;
  final ValueChanged<int> onMonthlyDaySelected;
  final ValueChanged<YearlySelection> onYearlySelectionChanged;

  const DynamicSection({
    super.key,
    required this.repetition,
    required this.simpleDate,
    required this.selectedWeekday,
    required this.monthlyDay,
    required this.yearlySelection,
    required this.onSimpleDateSelected,
    required this.onWeekdaySelected,
    required this.onMonthlyDaySelected,
    required this.onYearlySelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (repetition) {
      case IntervalType.simple:
        return SimpleDateSection(date: simpleDate, onDateSelected: onSimpleDateSelected);
      case IntervalType.weekly:
        return WeeklySection(selected: selectedWeekday, onDaySelected: onWeekdaySelected);
      case IntervalType.monthly:
        return MonthlySection(day: monthlyDay, onDaySelected: onMonthlyDaySelected);
      case IntervalType.yearly:
        return YearlySection(selection: yearlySelection, onSelectionChanged: onYearlySelectionChanged);
      default:
        return const SizedBox();
    }
  }
}