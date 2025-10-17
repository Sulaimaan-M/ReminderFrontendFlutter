import 'package:flutter/material.dart';
import '../model/reminder.dart';
import '../service/reminder_service.dart';
import 'create_reminder_screen.dart';

class ViewReminderScreen extends StatelessWidget {
  final Reminder reminder;

  const ViewReminderScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(reminder.remindAt);
    final time = _formatTime(reminder.remindAt);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reminder.reminderTxt,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Date', date),
            _buildDetailRow('Time', time),
            _buildDetailRow('Repeat', reminder.interval.label),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editReminder(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteReminder(context),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $ampm';
  }

  void _editReminder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReminderScreen(reminder: reminder),
      ),
    ).then((result) {
      if (result is Reminder && context.mounted) {
        Navigator.pop(context, result);
      }
    });
  }

  Future<void> _deleteReminder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ReminderService().deleteReminder(reminder.id!);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
          );
          Navigator.pop(context, reminder.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete')),
          );
        }
      }
    }
  }
}