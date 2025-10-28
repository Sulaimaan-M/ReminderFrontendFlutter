import 'package:flutter/material.dart';
import '../model/simple_task.dart';
import '../model/minimal_reminder.dart';
import '../model/detailed_reminder.dart';
import '../model/interval_type.dart';
import '../service/reminder_service.dart';
import '../service/task_service.dart';
import '../widget/todo/simple_task_card.dart';
import '../widget/todo/sections/simple_tasks_section.dart'; // NEW
import '../widget/todo/sections/reminders_section.dart'; // NEW
import '../widget/todo/sections/todo_headers.dart'; // NEW

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
  List<DetailedReminder> _detailedReminders = [];
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
      final taskService = TaskService();
      final deviceId = await taskService.getDeviceId();
      debugPrint('📱 TodoListScreen: Device ID = $deviceId');

      if (deviceId == null) {
        throw Exception('No device ID found');
      }

      final simpleTasks = await taskService.getSimpleTasksWithReminders();
      debugPrint('📥 TodoListScreen: Simple tasks with reminders = ${simpleTasks.length}');

      final reminderService = ReminderService();
      final detailedReminders = await reminderService.getPendingReminders();
      debugPrint('🔔 TodoListScreen: Detailed reminders = ${detailedReminders.length}');

      if (!mounted) return;

      setState(() {
        _simpleTasks = simpleTasks;
        _detailedReminders = detailedReminders;
        _loading = false;
        _sortSimpleTasks();
        _logSortingResults();
        debugPrint('✅ TodoListScreen: Data loaded successfully. Simple tasks: ${simpleTasks.length}, Detailed Reminders: ${detailedReminders.length}');
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
    _simpleTasks.sort((a, b) {
      final bool aHasReminder = a.reminder != null;
      final bool bHasReminder = b.reminder != null;

      if (aHasReminder && !bHasReminder) return -1;
      if (!aHasReminder && bHasReminder) return 1;
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

  Future<void> _onTaskUpdated() async {
    debugPrint('🔄 TodoListScreen: Task updated, reloading data...');
    await _loadAllData();
  }

  void _onReminderCompleted() {
    debugPrint('🔄 TodoListScreen: Reminder completed, reloading data...');
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: CustomScrollView(
        slivers: [
          const TodoHeader(title: 'One-Time Tasks'), // MODULARIZED
          if (_simpleTasks.isEmpty)
            const TodoEmptyState(text: 'No one-time tasks scheduled') // MODULARIZED
          else
            SimpleTasksSection( // MODULARIZED
              tasks: _simpleTasks,
              onTaskUpdated: _onTaskUpdated,
            ),

          const TodoDivider(), // MODULARIZED

          const TodoHeader(title: 'Reminders'), // MODULARIZED
          if (_detailedReminders.isEmpty)
            const TodoEmptyState(text: 'No reminders') // MODULARIZED
          else
            RemindersSection( // MODULARIZED
              reminders: _detailedReminders,
              onReminderCompleted: _onReminderCompleted,
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
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
}