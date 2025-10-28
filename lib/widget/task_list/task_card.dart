import 'package:flutter/material.dart';
import '../../model/task.dart';
import '../../model/interval_type.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getColorForType(task.interval),
          child: Icon(
            _getIconForType(task.interval),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          task.taskText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDateTime(task.nextReminderAt),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                task.interval.label,
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: _getColorForType(task.interval).withOpacity(0.2),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Color _getColorForType(IntervalType type) {
    switch (type) {
      case IntervalType.simple:
        return Colors.orange;
      case IntervalType.daily:
        return Colors.blue;
      case IntervalType.weekly:
        return Colors.green;
      case IntervalType.monthly:
        return Colors.purple;
      case IntervalType.yearly:
        return Colors.red;
    }
  }

  IconData _getIconForType(IntervalType type) {
    switch (type) {
      case IntervalType.simple:
        return Icons.event;
      case IntervalType.daily:
        return Icons.today;
      case IntervalType.weekly:
        return Icons.view_week;
      case IntervalType.monthly:
        return Icons.calendar_month;
      case IntervalType.yearly:
        return Icons.calendar_today;
    }
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