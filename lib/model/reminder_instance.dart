import 'reminder.dart';

class ReminderInstance {
  final int id;
  final String taskText;
  final DateTime remindedAt;
  final IntervalType taskType;

  ReminderInstance({
    required this.id,
    required this.taskText,
    required this.remindedAt,
    required this.taskType,
  });
}