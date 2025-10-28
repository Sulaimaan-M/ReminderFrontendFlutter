import 'package:flutter/material.dart';
import '../../model/task.dart';
import '../../model/interval_type.dart';

class TaskHeader extends StatelessWidget {
  final Task task;

  const TaskHeader({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.taskText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(
                label: Text(task.interval.label, style: const TextStyle(fontSize: 12)),
                backgroundColor: _typeColor(task.interval).withOpacity(0.15),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
              const SizedBox(width: 12),
              Icon(Icons.schedule_outlined, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Next: ${_formatDateTime(task.nextReminderAt)}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _typeColor(IntervalType type) {
    switch (type) {
      case IntervalType.simple: return Colors.orange;
      case IntervalType.daily:  return Colors.blue;
      case IntervalType.weekly: return Colors.green;
      case IntervalType.monthly:return Colors.purple;
      case IntervalType.yearly: return Colors.red;
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