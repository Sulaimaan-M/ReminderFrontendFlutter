import 'reminder.dart';

class TaskCreationData {
  final String taskText;
  final int deviceId;
  final IntervalType recurrenceType;
  final TimeDetail timeDetail;
  final RecurrencePattern recurrencePattern;

  TaskCreationData({
    required this.taskText,
    required this.deviceId,
    required this.recurrenceType,
    required this.timeDetail,
    required this.recurrencePattern,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskText': taskText,
      'deviceId': deviceId,
      'recurrenceType': recurrenceType.name.toUpperCase(),
      'timeDetail': timeDetail.toJson(),
      'recurrencePattern': recurrencePattern.toJson(),
    };
  }
}

class TimeDetail {
  final int seconds;
  final int minutes;
  final int hours;
  final String timezone;

  TimeDetail({
    required this.seconds,
    required this.minutes,
    required this.hours,
    required this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'seconds': seconds,
      'minutes': minutes,
      'hours': hours,
      'timezone': timezone,
    };
  }
}

class RecurrencePattern {
  final String dayOfMonth;
  final String dayOfWeek;
  final String month;
  final String year;

  RecurrencePattern({
    required this.dayOfMonth,
    required this.dayOfWeek,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayOfMonth': dayOfMonth,
      'dayOfWeek': dayOfWeek,
      'month': month,
      'year': year,
    };
  }
}