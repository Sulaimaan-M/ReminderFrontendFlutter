import 'package:flutter/material.dart';
import '../model/task.dart';
import '../model/reminder.dart'; // for IntervalType enum and labels
import '../service/task_service.dart';
import 'view_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> reload() async {
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskService = TaskService();
      final tasks = await taskService.getTasks();

      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a task using the + button',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final t = _tasks[index];
          return _buildTaskCard(t);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
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
        onTap: () => _openViewTask(task),
      ),
    );
  }

  void _openViewTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewTaskScreen(task: task),
      ),
    );
    // After coming back, refresh this tab's data
    await _loadTasks();
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
    final date = '${dt.month}/${dt.day}/${dt.year}';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$date at $hour:$minute $ampm';
  }
}