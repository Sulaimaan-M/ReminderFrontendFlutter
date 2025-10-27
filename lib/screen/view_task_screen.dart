import 'package:flutter/material.dart';
import '../model/task.dart';
import '../model/reminder.dart'; // Needed for IntervalType
import '../model/reminder_instance.dart';
import '../service/reminder_service.dart';
import '../service/task_service.dart';
import 'create_task_screen.dart'; // Ensure this import is correct

class ViewTaskScreen extends StatefulWidget {
  final Task task;
  const ViewTaskScreen({super.key, required this.task});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  // --- State variables correctly declared within the State class ---
  bool _loading = true;
  String? _error;
  List<ReminderInstance> _instances = [];
  // Store the task locally in state to potentially update it after edit
  late Task _currentTask;
  // ---

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task; // Initialize state task
    _loadInstances();
  }

  Future<void> _loadInstances() async {
    // Ensure mounted check happens correctly
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Use the ID from the state task
      final list = await ReminderService().getRemindersByTask(_currentTask.id!);
      if (!mounted) return;
      setState(() {
        _instances = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Failed to load reminder instances: ${e.toString()}"; // Add context
      });
    }
  }

  // --- Fetch updated task details (e.g., after edit) ---
  Future<void> _reloadTaskDetails() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; }); // Show loading for task reload too

    try {
      // Assuming TaskService().getTaskById exists or similar
      // For now, let's just refetch all tasks and find ours - replace if you have getTaskById
      final allTasks = await TaskService().getTasks();
      final updatedTask = allTasks.firstWhere((t) => t.id == widget.task.id, orElse: () => _currentTask); // Fallback to current if not found

      if (!mounted) return;
      setState(() {
        _currentTask = updatedTask; // Update the task in the state
        // Keep _loading = true until instances are also loaded
      });
      await _loadInstances(); // Reload instances after getting updated task details

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false; // Stop loading on error
        _error = "Failed to reload task details: ${e.toString()}";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Access state variables correctly within build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            // Refresh both task details and instances
            icon: const Icon(Icons.refresh),
            onPressed: _reloadTaskDetails, // Call the combined reload function
            tooltip: 'Refresh Task & Instances',
          ),
        ],
      ),
      body: Column(
        children: [
          // Use the _currentTask from state for the header
          _buildHeader(_currentTask),
          const Divider(height: 1),
          Expanded(
            child: _loading // Accessing state variable
                ? const Center(child: CircularProgressIndicator())
                : _error != null // Accessing state variable
                ? _buildError(_error!) // Accessing state variable
                : _instances.isEmpty // Accessing state variable
                ? const Center(child: Text('No reminder instances yet for this task'))
                : RefreshIndicator(
              onRefresh: _loadInstances, // Only reload instances on pull-to-refresh
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, top: 8), // Ensure space for FAB
                itemCount: _instances.length,
                itemBuilder: (context, index) {
                  final r = _instances[index]; // Accessing state variable
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: Icon( // Keep icon consistent
                        Icons.notifications_active_outlined,
                        color: Colors.grey[700],
                      ),
                      // Display reminder time prominently
                      title: Text('Reminded on: ${_formatDateTime(r.remindedAt)}'),
                      // Show task text if needed, maybe less prominent
                      // subtitle: Text(r.taskText, style: TextStyle(color: Colors.black87)),
                      trailing: IconButton(
                        icon: Icon(
                          r.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: r.isCompleted ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          // TODO: Implement API call to toggle completion status
                          // For now, just show a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('API call to toggle completion for instance ID ${r.id} not implemented yet.')),
                          );
                          // setState(() {
                          //   r.isCompleted = !r.isCompleted; // Visual toggle only
                          // });
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
            task.taskText, // Use task from argument
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Chip(
                label: Text(task.interval.label, style: TextStyle(fontSize: 12)), // Use task from argument
                backgroundColor: _typeColor(task.interval).withOpacity(0.15), // Use task from argument
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
              const SizedBox(width: 12),
              Icon(Icons.schedule_outlined, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  // Use task from argument and the corrected format function
                  'Next: ${_formatDateTime(task.nextReminderAt)}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Cron (UTC): ${task.cronExpression}', // Use task from argument
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
          Text(err, textAlign: TextAlign.center), // Display the error message passed in
          const SizedBox(height: 16),
          ElevatedButton.icon(
            // Retry should reload both task and instances
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
        color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white, // Use theme color
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
    // Use _currentTask here
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

    // Use _currentTask.id
    final ok = await TaskService().deleteTask(_currentTask.id!);

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted successfully')));
      Navigator.pop(context, true); // Pop ViewTaskScreen, signal success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete task. Please try again.')));
    }
  }

  Future<void> _onEdit() async {
    // Navigate passing the _currentTask from state
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CreateTaskScreen(task: _currentTask)),
    );

    if (!mounted) return;

    if (result == true) {
      // If editing was successful, refresh details and instances
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated. Refreshing...')));
      await _reloadTaskDetails(); // Reload both task details and instances
    }
  }


  String _formatDateTime(DateTime dt) {
    // Use .toLocal() before formatting
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