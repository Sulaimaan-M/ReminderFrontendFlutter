import 'reminder.dart';

class ReminderInstance {
  final int id;
  final String taskText;
  final DateTime remindedAt;
  final IntervalType taskType;
  bool isCompleted; // ← mutable to support in-place toggle in UI

  ReminderInstance({
    required this.id,
    required this.taskText,
    required this.remindedAt,
    required this.taskType,
    this.isCompleted = false,
  });
}