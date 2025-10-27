import 'reminder.dart';

class Task {
  final int? id;
  final String taskText;
  final DateTime? createdAt;
  final DateTime nextReminderAt;
  final String cronExpression;
  final IntervalType interval;
  final int deviceId;

  Task({
    required this.id,
    required this.taskText,
    required this.createdAt,
    required this.nextReminderAt,
    required this.cronExpression,
    required this.interval,
    required this.deviceId,
  });

  factory Task.fromBackendJson(Map<String, dynamic> json) {
    // Backend fields expected:
    // id, taskText, createdAt, nextReminderAt, cronExpression, recurrenceType, deviceId
    final recurrenceTypeStr = json['recurrenceType'] as String?;
    final interval = IntervalType.fromString(recurrenceTypeStr);

    DateTime? created;
    final createdStr = json['createdAt'] as String?;
    if (createdStr != null) {
      try {
        created = DateTime.parse(createdStr);
      } catch (_) {}
    }

    DateTime nextAt;
    final nextStr = json['nextReminderAt'] as String?;
    if (nextStr != null) {
      try {
        nextAt = DateTime.parse(nextStr);
      } catch (_) {
        nextAt = DateTime.now();
      }
    } else {
      nextAt = DateTime.now();
    }

    return Task(
      id: json['id'] as int?,
      taskText: json['taskText'] as String? ?? 'Untitled',
      createdAt: created,
      nextReminderAt: nextAt,
      cronExpression: json['cronExpression'] as String? ?? '* * * * * ? *',
      interval: interval,
      deviceId: json['deviceId'] as int? ?? 0,
    );
  }
}