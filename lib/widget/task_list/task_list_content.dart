import 'package:flutter/material.dart';
import 'package:reminder_app/widget/task_list/task_card.dart';
import '../../model/task.dart';

class TaskListContent extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<Task> tasks;
  final Future<void> Function() onRefresh;
  final Function(Task) onTaskTap;

  const TaskListContent({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.tasks,
    required this.onRefresh,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return _buildErrorWidget(context);
    }

    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks found'),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard( // MODULARIZED
            task: task,
            onTap: () => onTaskTap(task),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Error: $errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}