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
    final bool isCompleted = task.reminder?.isCompleted ?? false;

    final IconData trailingIconData = reminderExists
        ? (isCompleted ? Icons.check_circle : Icons.check_circle_outline)
        : Icons.notifications_none;

    final Color iconColor = reminderExists
        ? (isCompleted ? Colors.green : Colors.grey.shade600)
        : Theme.of(context).colorScheme.primary;

    final String tooltip = reminderExists
        ? (isCompleted ? 'Completed' : 'Mark as completed')
        : 'Pending reminder';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          task.taskTxt,
          style: TextStyle(
            fontSize: 16,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            _formatDateTime(task.nextReminderAt.toLocal()),
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