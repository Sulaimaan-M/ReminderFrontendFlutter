import 'package:flutter/material.dart';
import '../../model/simple_task.dart'; // Import the new SimpleTask model

class SimpleTaskCard extends StatelessWidget {
  // Use the new SimpleTask model
  final SimpleTask task;
  // Callback when the checkmark (action icon) is tapped
  final VoidCallback onActionTap;

  const SimpleTaskCard({
    super.key,
    required this.task, // Updated type
    required this.onActionTap, // Updated name
  });

  @override
  Widget build(BuildContext context) {
    // --- Logic based on reminder instance existence ---
    final bool reminderExists = task.reminder != null;

    final IconData trailingIconData = reminderExists
        ? Icons.check_circle_outline // Checkmark if reminder exists
        : Icons.notifications_none; // Bell if reminder is null

    final Color iconColor = reminderExists
        ? Colors.grey.shade600
        : Theme.of(context).colorScheme.primary;

    final String tooltip = reminderExists ? 'Mark as completed' : 'Pending';
    // --- End Logic ---

    // Determine if the reminder instance (if it exists) is marked completed
    final bool isCompleted = task.reminder?.isCompleted ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          task.taskText,
          style: TextStyle(
            fontSize: 16,
            // Add strikethrough if the reminder exists AND is completed
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey[600] : null, // Dim text if completed
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            // Format the original scheduled time
            _formatDateTime(task.remindAt.toLocal()),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              decoration: isCompleted ? TextDecoration.lineThrough : null, // Also strikethrough date
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(trailingIconData, color: iconColor),
          tooltip: tooltip,
          // Only enable the button if the reminder instance exists AND it's not already completed
          onPressed: (reminderExists && !isCompleted) ? onActionTap : null,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final date = '${dt.month}/${dt.day}/${dt.year}';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$date at $hour:$minute $ampm';
  }
}