import 'package:flutter/material.dart';
import '../../model/reminder_instance.dart';
import '../../service/reminder_service.dart';

class ReminderInstanceCard extends StatefulWidget {
  final ReminderInstance instance;
  final VoidCallback onCompleted; // Callback for when reminder is completed

  const ReminderInstanceCard({
    super.key,
    required this.instance,
    required this.onCompleted,
  });

  @override
  State<ReminderInstanceCard> createState() => _ReminderInstanceCardState();
}

class _ReminderInstanceCardState extends State<ReminderInstanceCard> {
  bool _isCompleting = false;

  Future<void> _handleComplete() async {
    setState(() {
      _isCompleting = true;
    });

    try {
      final reminderService = ReminderService();
      final success = await reminderService.completeReminder(widget.instance.id);

      if (success && mounted) {
        // Call the callback to notify parent about completion
        widget.onCompleted();

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
          widget.instance.taskText,
          style: TextStyle(
            fontSize: 16,
            decoration: widget.instance.isCompleted ? TextDecoration.lineThrough : null,
            color: widget.instance.isCompleted ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Reminded at: ${_formatDateTime(widget.instance.remindedAt)}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              decoration: widget.instance.isCompleted ? TextDecoration.lineThrough : null,
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
          icon: Icon(
            widget.instance.isCompleted
                ? Icons.check_circle
                : Icons.check_circle_outline,
            color: widget.instance.isCompleted
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
          ),
          tooltip: widget.instance.isCompleted
              ? 'Completed'
              : 'Mark as completed',
          onPressed: widget.instance.isCompleted ? null : _handleComplete,
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