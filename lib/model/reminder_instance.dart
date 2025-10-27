// lib/model/reminder_instance.dart
import 'interval_type.dart'; // Correct import

class ReminderInstance {
  final int id;
  final DateTime remindedAt;
  bool isCompleted;
  final String taskText;
  final int taskId; // Required
  final IntervalType taskType;

  ReminderInstance({
    required this.id,
    required this.remindedAt,
    required this.isCompleted,
    required this.taskText,
    required this.taskId, // Required field
    required this.taskType,
  });

  factory ReminderInstance.fromJson(Map<String, dynamic> json) {
    final String intervalStr = (json['taskType'] as String?)?.toLowerCase() ?? 'simple';
    IntervalType parsedInterval;
    try {
      parsedInterval = IntervalType.values.byName(intervalStr);
    } catch (_) {
      print('Warning: Unknown IntervalType string "$intervalStr" received for ReminderInstance. Defaulting to simple.');
      parsedInterval = IntervalType.simple; // Fallback
    }

    // --- CORRECTED: Ensure taskId is parsed and required ---
    final int? parsedTaskId = json['taskId'] as int?;
    if (parsedTaskId == null) {
      // Handle error: taskId is essential
      print('Error: Missing required field "taskId" in ReminderInstance JSON.');
      // You might want to throw an exception or return a default/error state
      // For now, defaulting to 0, but this indicates a problem.
    }
    // --- End Correction ---


    return ReminderInstance(
      id: json['id'] as int? ?? 0, // Provide default if null
      remindedAt: DateTime.parse(json['remindedAt'] ?? DateTime.now().toIso8601String()),
      isCompleted: json['isCompleted'] as bool? ?? false,
      taskText: json['taskText'] as String? ?? 'No Task Text',
      taskId: parsedTaskId ?? 0, // Use parsed taskId, provide default only as fallback
      taskType: parsedInterval,
    );
  }

  ReminderInstance copyWith({
    int? id,
    DateTime? remindedAt,
    bool? isCompleted,
    String? taskText,
    int? taskId,
    IntervalType? taskType,
  }) {
    return ReminderInstance(
      id: id ?? this.id,
      remindedAt: remindedAt ?? this.remindedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      taskText: taskText ?? this.taskText,
      taskId: taskId ?? this.taskId, // Include taskId in copyWith
      taskType: taskType ?? this.taskType,
    );
  }
}