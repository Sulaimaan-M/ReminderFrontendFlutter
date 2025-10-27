// lib/model/task.dart
import 'interval_type.dart'; // Correct import

class Task {
  final int? id; // Can be null if creating a new task locally
  final String taskText;
  final DateTime createdAt;
  final DateTime nextReminderAt;
  final String cronExpression; // Keep cron for potential display/debug
  final IntervalType interval; // Use the IntervalType enum
  final int deviceId;

  Task({
    this.id,
    required this.taskText,
    required this.createdAt,
    required this.nextReminderAt,
    required this.cronExpression,
    required this.interval,
    required this.deviceId,
  });

  factory Task.fromBackendJson(Map<String, dynamic> json) {
    final String intervalStr = (json['recurrenceType'] as String?)?.toLowerCase() ?? 'simple';

    // --- CORRECTED IntervalType parsing ---
    IntervalType parsedInterval;
    try {
      // Use .byName for direct lookup (requires enum names to match JSON strings exactly, ignoring case)
      // Or use firstWhere for more robust matching if needed
      parsedInterval = IntervalType.values.byName(intervalStr);
    } catch (_) {
      // Fallback if the string doesn't match any enum name
      print('Warning: Unknown IntervalType string "$intervalStr" received from backend. Defaulting to simple.');
      parsedInterval = IntervalType.simple;
    }
    // --- End Correction ---

    final String nextStr = json['nextReminderAt'] ?? DateTime.now().toIso8601String();
    final String createdStr = json['createdAt'] ?? DateTime.now().toIso8601String();


    return Task(
      id: json['id'] as int?,
      taskText: json['taskText'] as String? ?? 'Unnamed Task',
      // Ensure parsing handles potential timezone offsets correctly
      createdAt: DateTime.parse(createdStr),
      nextReminderAt: DateTime.parse(nextStr),
      cronExpression: json['cronExpression'] as String? ?? '',
      interval: parsedInterval, // Use the correctly parsed enum
      deviceId: json['deviceId'] as int? ?? 0, // Provide default if null
    );
  }

  // Add copyWith if needed
  Task copyWith({
    int? id,
    String? taskText,
    DateTime? createdAt,
    DateTime? nextReminderAt,
    String? cronExpression,
    IntervalType? interval,
    int? deviceId,
  }) {
    return Task(
      id: id ?? this.id,
      taskText: taskText ?? this.taskText,
      createdAt: createdAt ?? this.createdAt,
      nextReminderAt: nextReminderAt ?? this.nextReminderAt,
      cronExpression: cronExpression ?? this.cronExpression,
      interval: interval ?? this.interval,
      deviceId: deviceId ?? this.deviceId,
    );
  }

}