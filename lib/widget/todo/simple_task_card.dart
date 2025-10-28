import 'package:flutter/material.dart';
import '../../model/simple_task.dart';
import '../../service/reminder_service.dart';

class SimpleTaskCard extends StatefulWidget {
  final SimpleTask task;
  final VoidCallback onTaskUpdated; // NEW: Callback for when task data changes

  const SimpleTaskCard({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<SimpleTaskCard> createState() => _SimpleTaskCardState();
}

class _SimpleTaskCardState extends State<SimpleTaskCard> {
  bool _isCompleting = false;

  Future<void> _handleComplete() async {
    final reminderId = widget.task.reminder?.id;
    if (reminderId == null) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      final reminderService = ReminderService();
      final success = await reminderService.completeReminder(reminderId);

      if (success && mounted) {
        // Notify parent that task data may have changed
        widget.onTaskUpdated();

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completed successfully')),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete task')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error completing task')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- CORRECTED LOGIC BASED ON YOUR SPECIFICATION ---
    // Bell icon when reminder == null (no reminder yet)
    // Checkmark icon when reminder != null (reminder exists)
    final bool hasReminder = widget.task.reminder != null;
    final bool isCompleted = widget.task.reminder?.isCompleted ?? false;

    debugPrint('🎨 SimpleTaskCard build - Task ID: ${widget.task.id}, Has Reminder: $hasReminder, Completed: $isCompleted');

    IconData trailingIconData;
    Color iconColor;
    String tooltip;
    bool isActionable = false;

    if (hasReminder) {
      if (isCompleted) {
        // Completed reminder - green filled checkmark
        trailingIconData = Icons.check_circle;
        iconColor = Colors.green;
        tooltip = 'Reminder completed';
      } else {
        // Pending reminder - grey outline checkmark
        trailingIconData = Icons.check_circle_outline;
        iconColor = Colors.grey.shade600;
        tooltip = 'Reminder sent - mark as complete';
        isActionable = true; // Only actionable when reminder exists and not completed
      }
    } else {
      // No reminder yet - colored bell
      trailingIconData = Icons.notifications_none;
      iconColor = Theme.of(context).colorScheme.primary;
      tooltip = 'Waiting for reminder time';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          widget.task.taskTxt,
          style: TextStyle(
            fontSize: 16,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            _formatDateTime(widget.task.nextReminderAt.toLocal()),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        trailing: _isCompleting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : IconButton(
          icon: Icon(trailingIconData, color: iconColor),
          tooltip: tooltip,
          onPressed: isActionable ? _handleComplete : null,
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