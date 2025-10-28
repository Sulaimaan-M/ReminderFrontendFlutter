import 'package:flutter/material.dart';

class ReminderHistoryCard extends StatelessWidget {
  final DateTime remindedAt;
  final bool isCompleted;
  final int reminderId;

  const ReminderHistoryCard({
    super.key,
    required this.remindedAt,
    required this.isCompleted,
    required this.reminderId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          _formatDateTime(remindedAt),
          style: TextStyle(
            fontSize: 16,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey[600] : null,
          ),
        ),
        trailing: Icon(
          isCompleted ? Icons.check_circle : Icons.check_circle_outline,
          color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
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