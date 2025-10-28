import 'package:flutter/material.dart';
import '../model/task.dart';
import '../model/minimal_reminder.dart';
import '../service/reminder_service.dart';
import '../service/task_service.dart';
import 'create_task_screen.dart';
import '../widget/view_task/task_header.dart'; // NEW
import '../widget/view_task/reminders_list.dart'; // NEW
import '../widget/view_task/task_actions.dart'; // NEW

class ViewTaskScreen extends StatefulWidget {
  final Task task;
  const ViewTaskScreen({super.key, required this.task});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  bool _loading = true;
  String? _error;
  List<MinimalReminder> _instances = [];
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _loadInstances();
  }

  Future<void> _loadInstances() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Placeholder until backend endpoint is implemented
      final List<MinimalReminder> taskReminders = [];

      if (!mounted) return;
      setState(() {
        _instances = taskReminders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Failed to load reminder instances: ${e.toString()}";
      });
    }
  }

  Future<void> _reloadTaskDetails() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final allTasks = await TaskService().getTasks();
      final updatedTask = allTasks.firstWhere((t) => t.id == widget.task.id, orElse: () => _currentTask);

      if (!mounted) return;
      setState(() {
        _currentTask = updatedTask;
      });
      await _loadInstances();

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Failed to reload task details: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadTaskDetails,
            tooltip: 'Refresh Task & Instances',
          ),
        ],
      ),
      body: Column(
        children: [
          TaskHeader(task: _currentTask), // MODULARIZED
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError(_error!)
                : _instances.isEmpty
                ? const Center(child: Text('No reminder instances yet for this task'))
                : RefreshIndicator(
              onRefresh: _loadInstances,
              child: RemindersList( // MODULARIZED
                reminders: _instances,
                onReminderAction: (reminder) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('API call to toggle completion for instance ID ${reminder.id} not implemented yet.')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: TaskActions( // MODULARIZED
        onDelete: _onDelete,
        onEdit: _onEdit,
      ),
    );
  }

  Widget _buildError(String err) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(err, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _reloadTaskDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${_currentTask.taskText}"? This will unschedule future reminders.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final ok = await TaskService().deleteTask(_currentTask.id!);

    if (!mounted) return;
    Navigator.pop(context);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted successfully')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete task. Please try again.')));
    }
  }

  Future<void> _onEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CreateTaskScreen(task: _currentTask)),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated. Refreshing...')));
      await _reloadTaskDetails();
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