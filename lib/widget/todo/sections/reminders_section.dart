import 'package:flutter/material.dart';
import '../../../model/detailed_reminder.dart';

class RemindersSection extends StatelessWidget {
  final List<DetailedReminder> reminders;
  final VoidCallback onReminderCompleted;

  const RemindersSection({
    super.key,
    required this.reminders,
    required this.onReminderCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final detailedReminder = reminders[index];
        return _buildDetailedReminderCard(detailedReminder, context);
      },
    );
  }

  Widget _buildDetailedReminderCard(DetailedReminder reminder, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          reminder.taskTxt,
          style: TextStyle(
            fontSize: 16,
            decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
            color: reminder.isCompleted ? Colors.grey[600] : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminded at: ${_formatDateTime(reminder.remindedAt)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(reminder.recurrenceType, style: const TextStyle(fontSize: 10)),
                backgroundColor: _getColorForType(reminder.recurrenceType).withOpacity(0.2),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            reminder.isCompleted
                ? Icons.check_circle
                : Icons.check_circle_outline,
            color: reminder.isCompleted
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
          ),
          tooltip: reminder.isCompleted
              ? 'Completed'
              : 'Mark as completed',
          onPressed: reminder.isCompleted ? null : () => _handleReminderCompletion(reminder),
        ),
      ),
    );
  }

  Future<void> _handleReminderCompletion(DetailedReminder reminder) async {
    // This would be handled by the parent widget callback
    // For now, we'll just call the provided callback
    onReminderCompleted();
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