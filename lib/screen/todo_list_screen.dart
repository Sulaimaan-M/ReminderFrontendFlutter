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
      // Load simple tasks from backend
      final taskService = TaskService();
      final deviceId = await taskService.getDeviceId();
      debugPrint('📱 TodoListScreen: Device ID = $deviceId');

      if (deviceId == null) {
        throw Exception('No device ID found');
      }

      // Fetch both recurring and simple tasks
      final allTasks = await taskService.getTasks();
      debugPrint('📥 TodoListScreen: Total tasks fetched = ${allTasks.length}');

      // Load pending reminders
      final reminderService = ReminderService();
      final pendingReminders = await reminderService.getPendingReminders();
      debugPrint('🔔 TodoListScreen: Pending reminders = ${pendingReminders.length}');

      // Filter for simple tasks only
      final simpleTasks = allTasks.where((task) => task.interval == IntervalType.simple).toList();
      debugPrint('📋 TodoListScreen: Simple tasks = ${simpleTasks.length}');

      // Convert Task objects to SimpleTask objects with proper reminder status
      final List<SimpleTask> convertedSimpleTasks = simpleTasks.map((task) {
        // Check if this task has any pending reminders
        final taskReminders = pendingReminders.where((reminder) => reminder.taskId == task.id).toList();

        // For simple tasks, we typically expect 0 or 1 reminder instance
        MinimalReminder? reminderInstance;
        if (taskReminders.isNotEmpty) {
          final reminder = taskReminders.first;
          reminderInstance = MinimalReminder(
            id: reminder.id,
            remindedAt: reminder.remindedAt,
            isCompleted: reminder.isCompleted,
          );
          debugPrint('📌 TodoListScreen: Task ${task.id} has reminder ${reminder.id}');
        } else {
          debugPrint('⏰ TodoListScreen: Task ${task.id} has no reminders yet');
        }

        return SimpleTask(
          id: task.id ?? 0,
          taskTxt: task.taskText,
          nextReminderAt: task.nextReminderAt,
          reminder: reminderInstance,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _simpleTasks = convertedSimpleTasks;
        _reminderInstances = pendingReminders;
        _loading = false;
        _sortSimpleTasks();
        debugPrint('✅ TodoListScreen: Data loaded successfully. Simple tasks: ${convertedSimpleTasks.length}, Reminders: ${pendingReminders.length}');
      });
    } catch (e) {
      debugPrint('❌ TodoListScreen: Error loading data: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _sortSimpleTasks() {
    _simpleTasks.sort((a, b) {
      bool aHasReminder = a.reminder != null;
      bool bHasReminder = b.reminder != null;
      bool aIsCompleted = a.reminder?.isCompleted ?? false;
      bool bIsCompleted = b.reminder?.isCompleted ?? false;

      if (aIsCompleted && !bIsCompleted) return 1;
      if (!aIsCompleted && bIsCompleted) return -1;
      if (aHasReminder && !bHasReminder) return -1;
      if (!aHasReminder && bHasReminder) return 1;
      return a.nextReminderAt.compareTo(b.nextReminderAt);
    });
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
                debugPrint('📱 Building SimpleTaskCard for task ${simpleTask.id}: ${simpleTask.taskTxt}, Reminder: ${simpleTask.reminder?.id}, Completed: ${simpleTask.reminder?.isCompleted}');
                return SimpleTaskCard(
                  key: ValueKey('simple_task_${simpleTask.id}'),
                  task: simpleTask,
                  onActionTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mark Simple Task (ID: ${simpleTask.id}) as complete - API needed.')),
                    );
                    // TODO: Implement actual completion logic
                  },
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
                  onCompleted: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mark Instance (ID: ${inst.id}) as complete - API needed.')),
                    );
                    // TODO: Implement actual completion logic
                  },
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