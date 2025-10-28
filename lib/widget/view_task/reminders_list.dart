import 'package:flutter/material.dart';
import '../../model/minimal_reminder.dart';

class RemindersList extends StatelessWidget {
  final List<MinimalReminder> reminders;
  final Function(MinimalReminder) onReminderAction;

  const RemindersList({
    super.key,
    required this.reminders,
    required this.onReminderAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: Icon(
              Icons.notifications_active_outlined,
              color: Colors.grey[700],
            ),
            title: Text('Reminded on: ${_formatDateTime(reminder.remindedAt)}'),
            trailing: IconButton(
              icon: Icon(
                reminder.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: reminder.isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: () => onReminderAction(reminder),
              tooltip: reminder.isCompleted ? 'Mark incomplete (Not Implemented)' : 'Mark as completed (Not Implemented)',
            ),
          ),
        );
      },
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