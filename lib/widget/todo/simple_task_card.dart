import 'package:flutter/material.dart';
import '../../model/reminder.dart';

class SimpleTaskCard extends StatelessWidget {
  final Reminder task;
  final VoidCallback onCompleted;

  const SimpleTaskCard({
    super.key,
    required this.task,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: false,
          onChanged: (checked) {
            if (checked == true) {
              onCompleted();
            }
          },
        ),
        title: Text(task.reminderTxt),
        subtitle: Text(
          _formatDateTime(task.remindAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Chip(
          label: const Text('One-time', style: TextStyle(fontSize: 10)),
          backgroundColor: Colors.orange[100],
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