class DetailedReminder {
  // From Reminder
  final int reminderId;
  final DateTime remindedAt;
  final bool isCompleted;

  // From Task
  final int taskId;
  final String taskTxt;
  final String recurrenceType; // "DAILY", "WEEKLY", etc.

  DetailedReminder({
    required this.reminderId,
    required this.remindedAt,
    required this.isCompleted,
    required this.taskId,
    required this.taskTxt,
    required this.recurrenceType,
  });

  factory DetailedReminder.fromJson(Map<String, dynamic> json) {
    return DetailedReminder(
      reminderId: json['reminderId'] as int,
      remindedAt: DateTime.parse(json['remindedAt'] as String),
      isCompleted: json['isCompleted'] as bool,
      taskId: json['taskId'] as int,
      taskTxt: json['taskTxt'] as String,
      recurrenceType: json['recurrenceType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderId': reminderId,
      'remindedAt': remindedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'taskId': taskId,
      'taskTxt': taskTxt,
      'recurrenceType': recurrenceType,
    };
  }
}