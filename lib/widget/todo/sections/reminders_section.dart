import 'package:flutter/material.dart';
import '../../../model/detailed_reminder.dart';
import '../../../service/reminder_service.dart';

class RemindersSection extends StatefulWidget {
  final List<DetailedReminder> reminders;
  final VoidCallback onReminderCompleted;

  const RemindersSection({
    super.key,
    required this.reminders,
    required this.onReminderCompleted,
  });

  @override
  State<RemindersSection> createState() => _RemindersSectionState();
}

class _RemindersSectionState extends State<RemindersSection> {
  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.reminders.length,
      itemBuilder: (context, index) {
        final detailedReminder = widget.reminders[index];
        return _ReminderCard(
          reminder: detailedReminder,
          onReminderUpdated: widget.onReminderCompleted,
        );
      },
    );
  }
}

class _ReminderCard extends StatefulWidget {
  final DetailedReminder reminder;
  final VoidCallback onReminderUpdated;

  const _ReminderCard({
    required this.reminder,
    required this.onReminderUpdated,
  });

  @override
  State<_ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<_ReminderCard> {
  bool _isCompleting = false;

  Future<void> _handleComplete() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      final reminderService = ReminderService();
      final success = await reminderService.completeReminder(widget.reminder.reminderId);

      if (success && mounted) {
        // Notify parent to refresh the list
        widget.onReminderUpdated();

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder marked as completed')),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete reminder')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error completing reminder')),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          widget.reminder.taskTxt,
          style: TextStyle(
            fontSize: 16,
            decoration: widget.reminder.isCompleted ? TextDecoration.lineThrough : null,
            color: widget.reminder.isCompleted ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminded at: ${_formatDateTime(widget.reminder.remindedAt)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  decoration: widget.reminder.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(widget.reminder.recurrenceType, style: const TextStyle(fontSize: 10)),
                backgroundColor: _getColorForType(widget.reminder.recurrenceType).withOpacity(0.2),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        trailing: _isCompleting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : IconButton(
          icon: Icon(
            widget.reminder.isCompleted
                ? Icons.check_circle
                : Icons.check_circle_outline,
            color: widget.reminder.isCompleted
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
          ),
          tooltip: widget.reminder.isCompleted
              ? 'Completed'
              : 'Mark as completed',
          onPressed: widget.reminder.isCompleted ? null : _handleComplete,
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'simple':
        return Colors.orange;
      case 'daily':
        return Colors.blue;
      case 'weekly':
        return Colors.green;
      case 'monthly':
        return Colors.purple;
      case 'yearly':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dt) {
    final date = '${dt.month}/${dt.day}/${dt.year}';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$date at $hour:$minute $ampm';
  }
}