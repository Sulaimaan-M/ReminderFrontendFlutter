import 'package:flutter/material.dart';
import '../../../model/simple_task.dart';
import '../simple_task_card.dart';

class SimpleTasksSection extends StatelessWidget {
  final List<SimpleTask> tasks;
  final VoidCallback onTaskUpdated;

  const SimpleTasksSection({
    super.key,
    required this.tasks,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final simpleTask = tasks[index];
        debugPrint('📱 Building SimpleTaskCard ${index + 1}/${tasks.length} - Task ID: ${simpleTask.id}, Has Reminder: ${simpleTask.reminder != null}, Reminder ID: ${simpleTask.reminder?.id}');
        return SimpleTaskCard(
          key: ValueKey('simple_task_${simpleTask.id}'),
          task: simpleTask,
          onTaskUpdated: onTaskUpdated,
        );
      },
    );
  }
}