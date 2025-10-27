import 'package:flutter/material.dart';
import '../../model/reminder_instance.dart';

class ReminderInstanceCard extends StatelessWidget {
  final ReminderInstance instance;
  final VoidCallback onCompleted;

  const ReminderInstanceCard({
    super.key,
    required this.instance,
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
        title: Text(instance.taskText),
        subtitle: Text(
          'Reminded at: ${_formatDateTime(instance.remindedAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Chip(
          label: Text(instance.taskType.label, style: const TextStyle(fontSize: 10)),
          backgroundColor: Colors.blue[100],
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