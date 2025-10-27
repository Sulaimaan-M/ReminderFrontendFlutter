import 'reminder_instance.dart'; // Import the model for the fired reminder

class SimpleTask {
  final int id; // Assuming ID is always present for tasks shown here
  final String taskText;
  final DateTime remindAt;
  final ReminderInstance? reminder; // Nullable instance of the fired reminder

  SimpleTask({
    required this.id,
    required this.taskText,
    required this.remindAt,
    this.reminder, // Optional in constructor
  });

  // Add copyWith or other helpers if needed later
  SimpleTask copyWith({
    int? id,
    String? taskText,
    DateTime? remindAt,
    ReminderInstance? reminder,
    bool clearReminder = false,
  }) {
    return SimpleTask(
      id: id ?? this.id,
      taskText: taskText ?? this.taskText,
      remindAt: remindAt ?? this.remindAt,
      reminder: clearReminder ? null : reminder ?? this.reminder,
    );
  }

// Add fromJson if you plan to fetch these from backend later
// factory SimpleTask.fromJson(Map<String, dynamic> json) { ... }
}