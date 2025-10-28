import 'package:flutter/material.dart';
import '../model/simple_task.dart';
import '../model/minimal_reminder.dart';
import '../model/reminder_instance.dart';
import '../model/interval_type.dart';
import '../service/reminder_service.dart';
import '../service/task_service.dart';
import '../widget/todo/simple_task_card.dart';
import '../widget/todo/reminder_instance_card.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<SimpleTask> _simpleTasks = [];
  List<ReminderInstance> _reminderInstances = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> reload() async {
    if (!mounted) return;
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    debugPrint('🔄 TodoListScreen: Loading all data...');

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load simple tasks using the new method that preserves reminder data
      final taskService = TaskService();
      final deviceId = await taskService.getDeviceId();
      debugPrint('📱 TodoListScreen: Device ID = $deviceId');

      if (deviceId == null) {
        throw Exception('No device ID found');
      }

      // Use the new method that gets simple tasks with embedded reminder data
      final simpleTasks = await taskService.getSimpleTasksWithReminders();
      debugPrint('📥 TodoListScreen: Simple tasks with reminders = ${simpleTasks.length}');

      // Load pending reminders for other sections
      final reminderService = ReminderService();
      final pendingReminders = await reminderService.getPendingReminders();
      debugPrint('🔔 TodoListScreen: Pending reminders = ${pendingReminders.length}');

      if (!mounted) return;

      setState(() {
        _simpleTasks = simpleTasks;
        _reminderInstances = pendingReminders;
        _loading = false;
        _sortSimpleTasks();
        _logSortingResults(); // Log the final sorting results for verification
        debugPrint('✅ TodoListScreen: Data loaded successfully. Simple tasks: ${simpleTasks.length}, Reminders: ${pendingReminders.length}');
      });
    } catch (e, stackTrace) {
      debugPrint('❌ TodoListScreen: Error loading data: $e');
      debugPrint('StackTrace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _sortSimpleTasks() {
    // Sort according to specification:
    // Tasks with reminders (checkmark) at the top
    // Tasks without reminders (bell) at the bottom
    // Within each group, sort by next reminder time

    _simpleTasks.sort((a, b) {
      final bool aHasReminder = a.reminder != null;
      final bool bHasReminder = b.reminder != null;

      // Primary sort: tasks with reminders first
      if (aHasReminder && !bHasReminder) return -1;  // a (has reminder) comes first
      if (!aHasReminder && bHasReminder) return 1;   // b (has reminder) comes first

      // Secondary sort: by next reminder time (ascending)
      return a.nextReminderAt.compareTo(b.nextReminderAt);
    });
  }

  void _logSortingResults() {
    debugPrint('📊 Sorting Results:');
    for (int i = 0; i < _simpleTasks.length; i++) {
      final task = _simpleTasks[i];
      final hasReminder = task.reminder != null;
      final isCompleted = task.reminder?.isCompleted ?? false;
      debugPrint('   $i. Task ${task.id}: "${task.taskTxt}" | Reminder: ${hasReminder ? 'YES' : 'NO'} | Completed: $isCompleted | Time: ${task.nextReminderAt}');
    }
  }

  // Called when a task is updated/completed
  Future<void> _onTaskUpdated() async {
    debugPrint('🔄 TodoListScreen: Task updated, reloading data...');
    await _loadAllData(); // Reload all data to reflect changes
  }

  // Called when a reminder instance is completed
  void _onReminderCompleted() {
    debugPrint('🔄 TodoListScreen: Reminder completed, reloading data...');
    _loadAllData(); // Reload data to reflect changes
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: CustomScrollView(
        slivers: [
          // Simple Tasks
          _header(context, 'One-Time Tasks'),
          if (_simpleTasks.isEmpty)
            _emptyText('No one-time tasks scheduled')
          else
            SliverList.builder(
              itemCount: _simpleTasks.length,
              itemBuilder: (context, index) {
                final simpleTask = _simpleTasks[index];
                debugPrint('📱 Building SimpleTaskCard ${index + 1}/${_simpleTasks.length} - Task ID: ${simpleTask.id}, Has Reminder: ${simpleTask.reminder != null}, Reminder ID: ${simpleTask.reminder?.id}');
                return SimpleTaskCard(
                  key: ValueKey('simple_task_${simpleTask.id}'),
                  task: simpleTask,
                  onTaskUpdated: _onTaskUpdated,
                );
              },
            ),

          _divider(),

          // Upcoming Reminders
          _header(context, 'Upcoming Reminders'),
          if (_reminderInstances.isEmpty)
            _emptyText('No upcoming reminders')
          else
            SliverList.builder(
              itemCount: _reminderInstances.length,
              itemBuilder: (context, index) {
                final inst = _reminderInstances[index];
                return ReminderInstanceCard(
                  key: ValueKey('instance_${inst.id}'),
                  instance: inst,
                  onCompleted: _onReminderCompleted, // Updated callback
                );
              },
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // --- Helper Widgets remain the same ---
  SliverToBoxAdapter _header(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _emptyText(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Center(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 16))),
      ),
    );
  }

  SliverToBoxAdapter _divider() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Divider(thickness: 1, color: Colors.grey[300]),
      ),
    );
  }
}