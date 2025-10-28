import 'package:flutter/material.dart';
import '../model/interval_type.dart';
import '../model/task.dart';
import '../model/reminder_instance.dart';
import '../service/reminder_service.dart';
import '../service/task_service.dart';
import 'create_task_screen.dart';

class ViewTaskScreen extends StatefulWidget {
  final Task task;
  const ViewTaskScreen({super.key, required this.task});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  bool _loading = true;
  String? _error;
  List<ReminderInstance> _instances = [];
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
      // Since we don't have getRemindersByTask endpoint, we'll use pending reminders
      // and filter by task ID, or show a message that this feature needs backend implementation
      final allPendingReminders = await ReminderService().getPendingReminders();
      final taskReminders = allPendingReminders.where((reminder) => reminder.taskId == _currentTask.id).toList();

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
          _buildHeader(_currentTask),
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
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, top: 8),
                itemCount: _instances.length,
                itemBuilder: (context, index) {
                  final r = _instances[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.grey[700],
                      ),
                      title: Text('Reminded on: ${_formatDateTime(r.remindedAt)}'),
                      trailing: IconButton(
                        icon: Icon(
                          r.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: r.isCompleted ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('API call to toggle completion for instance ID ${r.id} not implemented yet.')),
                          );
                        },
                        tooltip: r.isCompleted ? 'Mark incomplete (Not Implemented)' : 'Mark as completed (Not Implemented)',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(Task task) {
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Cron (UTC): ${task.cronExpression}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
        ],
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete Task', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Task'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
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

  Color _typeColor(IntervalType type) {
    switch (type) {
      case IntervalType.simple: return Colors.orange;
      case IntervalType.daily:  return Colors.blue;
      case IntervalType.weekly: return Colors.green;
      case IntervalType.monthly:return Colors.purple;
      case IntervalType.yearly: return Colors.red;
    }
  }
}