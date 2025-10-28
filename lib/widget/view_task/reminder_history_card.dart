import 'package:flutter/material.dart';
import '../../service/reminder_service.dart';

class ReminderHistoryCard extends StatefulWidget {
  final DateTime remindedAt;
  final bool isCompleted;
  final int reminderId;
  final VoidCallback onReminderUpdated; // NEW: Callback for refresh

  const ReminderHistoryCard({
    super.key,
    required this.remindedAt,
    required this.isCompleted,
    required this.reminderId,
    required this.onReminderUpdated, // NEW
  });

  @override
  State<ReminderHistoryCard> createState() => _ReminderHistoryCardState();
}

class _ReminderHistoryCardState extends State<ReminderHistoryCard> {
  bool _isCompleting = false;

  Future<void> _handleComplete() async {
    if (_isCompleting) return; // Prevent double tap

    setState(() {
      _isCompleting = true;
    });

    try {
      final reminderService = ReminderService();
      final success = await reminderService.completeReminder(widget.reminderId);

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          _formatDateTime(widget.remindedAt),
          style: TextStyle(
            fontSize: 16,
            decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
            color: widget.isCompleted ? Colors.grey[600] : null,
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
            widget.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            color: widget.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
          ),
          onPressed: widget.isCompleted ? null : _handleComplete, // Only actionable if not completed
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final localDt = dt.toLocal();
    final date = '${localDt.month}/${localDt.day}/${localDt.year}';
    final hour = localDt.hour % 12 == 0 ? 12 : localDt.hour % 12;
    final minute = localDt.minute.toString().padLeft(2, '0');
    final ampm = localDt.hour < 12 ? 'AM' : 'PM';
    return '$date at $hour:$minute $ampm';
  }
}