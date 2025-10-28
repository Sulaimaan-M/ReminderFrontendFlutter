import 'minimal_reminder.dart';

class SimpleTask {
  final int id;
  final String taskTxt;
  final DateTime nextReminderAt;
  final MinimalReminder? reminder; // Nullable - null until reminder time arrives

  SimpleTask({
    required this.id,
    required this.taskTxt,
    required this.nextReminderAt,
    this.reminder, // Optional/nullable
  });

  // Factory constructor to create from JSON
  factory SimpleTask.fromJson(Map<String, dynamic> json) {
    return SimpleTask(
      id: json['id'] as int,
      taskTxt: json['taskTxt'] as String,
      nextReminderAt: DateTime.parse(json['nextReminderAt'] as String),
      reminder: json['reminder'] != null
          ? MinimalReminder.fromJson(json['reminder'] as Map<String, dynamic>)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskTxt': taskTxt,
      'nextReminderAt': nextReminderAt.toIso8601String(),
      'reminder': reminder?.toJson(),
    };
  }
}