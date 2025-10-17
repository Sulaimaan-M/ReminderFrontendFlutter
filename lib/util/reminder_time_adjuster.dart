
import '../model/reminder.dart';

class ReminderTimeAdjuster {
  static DateTime adjustToFuture(DateTime remindAt, IntervalType interval) {
    final now = DateTime.now();

    if (remindAt.isAfter(now)) {
      return remindAt;
    }

    switch (interval) {
      case IntervalType.simple:
        return DateTime(
          now.year,
          now.month,
          now.day + 1,
          remindAt.hour,
          remindAt.minute,
          remindAt.second,
        );

      case IntervalType.daily:
        var adjusted = remindAt;
        while (!adjusted.isAfter(now)) {
          adjusted = adjusted.add(const Duration(days: 1));
        }
        return adjusted;

      case IntervalType.weekly:
        var adjusted = remindAt;
        while (!adjusted.isAfter(now)) {
          adjusted = adjusted.add(const Duration(days: 7));
        }
        return adjusted;

      case IntervalType.monthly:
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
        var adjusted = remindAt;
        while (!adjusted.isAfter(now)) {
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