class RecurringTask {
  final int id;
  final String taskTxt;
  final String recurrenceType; // "DAILY", "WEEKLY", "MONTHLY", etc.
  final DateTime nextReminderAt;

  RecurringTask({
    required this.id,
    required this.taskTxt,
    required this.recurrenceType,
    required this.nextReminderAt,
  });

  factory RecurringTask.fromJson(Map<String, dynamic> json) {
    return RecurringTask(
      id: json['id'] as int,
      taskTxt: json['taskTxt'] as String,
      recurrenceType: json['recurrenceType'] as String,
      nextReminderAt: DateTime.parse(json['nextReminderAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskTxt': taskTxt,
      'recurrenceType': recurrenceType,
      'nextReminderAt': nextReminderAt.toIso8601String(),
    };
  }
}