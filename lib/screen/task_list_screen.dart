import 'package:flutter/material.dart';
import '../model/task.dart';
import '../service/task_service.dart';
import 'view_task_screen.dart';
import '../widget/task_list/task_list_content.dart';

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

  void _openViewTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewTaskScreen(task: task),
      ),
    );
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TaskListContent( // MODULARIZED
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      tasks: _tasks,
      onRefresh: _loadTasks,
      onTaskTap: _openViewTask,
    );
  }
}