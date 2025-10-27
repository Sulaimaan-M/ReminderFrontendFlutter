import 'package:flutter/material.dart';
import '../model/task.dart';
import '../model/reminder.dart';
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

  @override
  void initState() {
    super.initState();
    _loadInstances();
  }

  Future<void> _loadInstances() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await ReminderService().getRemindersByTask(widget.task.id!);
      if (!mounted) return;
      setState(() {
        _instances = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInstances,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(task),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError(_error!)
                : _instances.isEmpty
                ? const Center(child: Text('No reminder instances yet'))
                : RefreshIndicator(
              onRefresh: _loadInstances,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _instances.length,
                itemBuilder: (context, index) {
                  final r = _instances[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.black87,
                      ),
                      title: Text(r.taskText),
                      subtitle: Text(
                        _formatDateTime(r.remindedAt),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          r.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: r.isCompleted ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          // Future: call API to complete, then _loadInstances()
                          setState(() {
                            r.isCompleted = !r.isCompleted;
                          });
                        },
                        tooltip: r.isCompleted ? 'Completed' : 'Mark as completed',
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
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.taskText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(task.interval.label),
                backgroundColor: _typeColor(task.interval).withOpacity(0.15),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.schedule, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Next: ${_formatDateTime(task.nextReminderAt)}',
                style: const TextStyle(color: Colors.black87),
              ),
            ],
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
          Text('Failed to load reminders: $err'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadInstances,
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
        color: Colors.white,
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
                label: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
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
        content: const Text('This will remove the task and unschedule future reminders.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await TaskService().deleteTask(widget.task.id!);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete task')));
    }
  }

  Future<void> _onEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTaskScreen(task: widget.task)),
    );
    if (!mounted) return;

    if (result == true) {
      await _loadInstances();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated')));
    }
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final date = '${d.month}/${d.day}/${d.year}';
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
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