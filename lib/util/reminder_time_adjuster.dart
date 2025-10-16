// lib/util/reminder_time_adjuster.dart

import '../model/reminder.dart';

class ReminderTimeAdjuster {
  /// Adjusts remindAt to the next future occurrence based on interval
  static DateTime adjustToFuture(DateTime remindAt, IntervalType interval) {
    final now = DateTime.now();

    // If already in future, return as-is
    if (remindAt.isAfter(now)) {
      return remindAt;
    }

    // Adjust based on interval type
    switch (interval) {
      case IntervalType.simple:
      // For simple reminders, set to same time tomorrow
        return DateTime(
          now.year,
          now.month,
          now.day + 1,
          remindAt.hour,
          remindAt.minute,
          remindAt.second,
        );

      case IntervalType.daily:
      // Add days until future
        var adjusted = remindAt;
        while (!adjusted.isAfter(now)) {
          adjusted = adjusted.add(const Duration(days: 1));
        }
        return adjusted;

      case IntervalType.weekly:
      // Add weeks until future
        var adjusted = remindAt;
        while (!adjusted.isAfter(now)) {
          adjusted = adjusted.add(const Duration(days: 7));
        }
        return adjusted;

      case IntervalType.monthly:
      // Add months until future
        var adjusted = remindAt;
        while (!adjusted.isAfter(now)) {
          // Handle month overflow (e.g., Jan 31 + 1 month = Feb 28/29)
          final nextMonth = adjusted.month == 12 ? 1 : adjusted.month + 1;
          final nextYear = adjusted.month == 12 ? adjusted.year + 1 : adjusted.year;
          final daysInNextMonth = _daysInMonth(nextYear, nextMonth);
          final day = adjusted.day > daysInNextMonth ? daysInNextMonth : adjusted.day;

          adjusted = DateTime(nextYear, nextMonth, day, adjusted.hour, adjusted.minute, adjusted.second);
        }
        return adjusted;

      case IntervalType.yearly:
      // Add years until future
        var adjusted = remindAt;
        while (!adjusted.isAfter(now)) {
          // Handle leap year (Feb 29)
          if (adjusted.month == 2 && adjusted.day == 29) {
            final nextYear = adjusted.year + 1;
            final isLeap = _isLeapYear(nextYear);
            final day = isLeap ? 29 : 28;
            adjusted = DateTime(nextYear, 2, day, adjusted.hour, adjusted.minute, adjusted.second);
          } else {
            adjusted = DateTime(adjusted.year + 1, adjusted.month, adjusted.day, adjusted.hour, adjusted.minute, adjusted.second);
          }
        }
        return adjusted;
    }
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    }
    return <int>[31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1];
  }

  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}