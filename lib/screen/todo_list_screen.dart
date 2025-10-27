import 'package:flutter/material.dart';
import '../model/simple_task.dart';
import '../model/reminder_instance.dart';
import '../model/interval_type.dart';
import '../service/reminder_service.dart';
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

  // --- Use SimpleTask for dummy data ---
  final List<SimpleTask> _simpleTasks = [
    // Task where reminder *has* fired (has reminder instance)
    SimpleTask(
      id: 2,
      taskText: 'Buy groceries (Reminder Exists)',
      remindAt: DateTime.now().subtract(const Duration(hours: 3)),
      reminder: ReminderInstance(
        id: 101,
        remindedAt: DateTime.now().subtract(const Duration(hours: 3)),
        isCompleted: false,
        taskText: 'Buy groceries (Reminder Exists)',
        taskId: 2, // --- CORRECTED: Added required taskId ---
        taskType: IntervalType.simple,
      ),
    ),
    // Task where reminder has *not* fired yet (reminder instance is null)
    SimpleTask(
      id: 1,
      taskText: 'Doctor appointment (Reminder Null)',
      remindAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
      reminder: null,
    ),
    // Another task where reminder has *not* fired yet
    SimpleTask(
      id: 3,
      taskText: 'Call plumber (Reminder Null)',
      remindAt: DateTime.now().add(const Duration(minutes: 30)),
      reminder: null,
    ),
    // Task where reminder *has* fired AND is marked completed
    SimpleTask(
      id: 4,
      taskText: 'Pay bills (Reminder Exists, Completed)',
      remindAt: DateTime.now().subtract(const Duration(days: 2)),
      reminder: ReminderInstance(
        id: 102,
        remindedAt: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: true,
        taskText: 'Pay bills (Reminder Exists, Completed)',
        taskId: 4, // --- CORRECTED: Added required taskId ---
        taskType: IntervalType.simple,
      ),
    ),
  ];
  // --- End Dummy Data ---

  List<ReminderInstance> _reminderInstances = [];
  bool _loadingReminders = true;
  String? _errorReminders;

  @override
  void initState() {
    super.initState();
    _loadPendingReminders();
    _sortSimpleTasks();
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
      return a.remindAt.compareTo(b.remindAt);
    });
  }


  Future<void> reload() async {
    if (!mounted) return;
    setStateIfMounted(() {
      _loadingReminders = true;
      _errorReminders = null;
      _sortSimpleTasks();
    });
    await _loadPendingReminders();
  }

  Future<void> _loadPendingReminders() async {
    if (!mounted) return;
    setStateIfMounted(() {
      _loadingReminders = true;
      _errorReminders = null;
    });

    try {
      final service = ReminderService();
      final list = await service.getPendingReminders();
      setStateIfMounted(() {
        _reminderInstances = list;
        _loadingReminders = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _loadingReminders = false;
        _errorReminders = e.toString();
      });
    }
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: reload,
      child: CustomScrollView(
        slivers: [
          // Simple Tasks
          _header(context, 'One-Time Tasks'),
          if (_loadingReminders && _simpleTasks.isEmpty)
            SliverToBoxAdapter(/* Loading */)
          else if (_simpleTasks.isEmpty)
            _emptyText('No one-time tasks scheduled')
          else
            SliverList.builder(
              itemCount: _simpleTasks.length,
              itemBuilder: (context, index) {
                final simpleTask = _simpleTasks[index];
                return SimpleTaskCard(
                  key: ValueKey('simple_task_${simpleTask.id}'),
                  task: simpleTask,
                  // --- CORRECTED: Use onMarkComplete callback name ---
                  onActionTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mark Simple Task (ID: ${simpleTask.id}, ReminderID: ${simpleTask.reminder?.id}) as complete - API needed.')),
                    );
                    setStateIfMounted(() {
                      final taskIndex = _simpleTasks.indexWhere((t) => t.id == simpleTask.id);
                      if (taskIndex != -1 && _simpleTasks[taskIndex].reminder != null) {
                        final updatedReminder = _simpleTasks[taskIndex].reminder!.copyWith(isCompleted: true);
                        _simpleTasks[taskIndex] = _simpleTasks[taskIndex].copyWith(reminder: updatedReminder);
                        _sortSimpleTasks();
                      }
                    });
                  },
                );
              },
            ),

          _divider(),

          // Upcoming Reminders
          _header(context, 'Upcoming Reminders'),
          if (_loadingReminders)
            SliverToBoxAdapter(/* Loading */)
          else if (_errorReminders != null)
            SliverToBoxAdapter(child: _buildErrorWidget(_errorReminders!, _loadPendingReminders))
          else if (_reminderInstances.isEmpty)
              _emptyText('No upcoming reminders')
            else
              SliverList.builder(
                itemCount: _reminderInstances.length,
                itemBuilder: (context, index) {
                  final inst = _reminderInstances[index];
                  return ReminderInstanceCard(
                    key: ValueKey('instance_${inst.id}'),
                    instance: inst,
                    onCompleted: () { // This one correctly uses onCompleted
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mark Instance (ID: ${inst.id}) as complete - API needed.')),
                      );
                      setStateIfMounted(() {
                        final instanceIndex = _reminderInstances.indexWhere((i) => i.id == inst.id);
                        if(instanceIndex != -1) {
                          _reminderInstances[instanceIndex] = inst.copyWith(isCompleted: true);
                        }
                      });
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

  Widget _buildErrorWidget(String errorMsg, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 48),
          const SizedBox(height: 16),
          Text('Failed to load reminders', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(errorMsg, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
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