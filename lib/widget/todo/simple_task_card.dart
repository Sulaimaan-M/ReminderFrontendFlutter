import 'package:flutter/material.dart';

import '../../model/simple_task.dart';


class SimpleTaskCard extends StatelessWidget {
  final SimpleTask task;
  final VoidCallback onActionTap;

  const SimpleTaskCard({
    super.key,
    required this.task,
    required this.onActionTap,
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
          task.taskTxt, // ← UPDATED
          style: TextStyle(
            fontSize: 16,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            _formatDateTime(task.nextReminderAt.toLocal()), // ← UPDATED
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(trailingIconData, color: iconColor),
          tooltip: tooltip,
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