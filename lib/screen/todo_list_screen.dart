import 'package:flutter/material.dart';
import '../model/reminder.dart';
import '../model/reminder_instance.dart';
import '../widget/todo/simple_task_card.dart';
import '../widget/todo/reminder_instance_card.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<Reminder> _simpleTasks = [
    Reminder(
      id: 1,
      reminderTxt: 'Doctor appointment',
      remindAt: DateTime(2025, 10, 28, 15, 30),
      interval: IntervalType.simple,
      deviceId: 1,
    ),
    Reminder(
      id: 2,
      reminderTxt: 'Pay electricity bill',
      remindAt: DateTime(2025, 10, 30, 10, 0),
      interval: IntervalType.simple,
      deviceId: 1,
    ),
    Reminder(
      id: 3,
      reminderTxt: 'Submit project report',
      remindAt: DateTime(2025, 11, 1, 17, 0),
      interval: IntervalType.simple,
      deviceId: 1,
    ),
  ];

  final List<ReminderInstance> _reminderInstances = [
    ReminderInstance(
      id: 101,
      taskText: 'Take morning medicine',
      remindedAt: DateTime(2025, 10, 26, 9, 0),
      taskType: IntervalType.daily,
    ),
    ReminderInstance(
      id: 102,
      taskText: 'Weekly team meeting',
      remindedAt: DateTime(2025, 10, 21, 14, 0),
      taskType: IntervalType.weekly,
    ),
    ReminderInstance(
      id: 103,
      taskText: 'Workout session',
      remindedAt: DateTime(2025, 10, 25, 18, 30),
      taskType: IntervalType.daily,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        _buildSectionHeader(context, 'Simple Tasks'),
        _buildSimpleTasksList(),
        _buildDivider(),
        _buildSectionHeader(context, 'Reminders'),
        _buildReminderInstancesList(),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTasksList() {
    if (_simpleTasks.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'No simple tasks',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final task = _simpleTasks[index];
          return SimpleTaskCard(
            task: task,
            onCompleted: () {
              setState(() {
                _simpleTasks.removeWhere((t) => t.id == task.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${task.reminderTxt} completed!')),
              );
            },
          );
        },
        childCount: _simpleTasks.length,
      ),
    );
  }

  Widget _buildReminderInstancesList() {
    if (_reminderInstances.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'No reminders',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final instance = _reminderInstances[index];
          return ReminderInstanceCard(
            instance: instance,
            onCompleted: () {
              setState(() {
                _reminderInstances.removeWhere((r) => r.id == instance.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${instance.taskText} completed!')),
              );
            },
          );
        },
        childCount: _reminderInstances.length,
      ),
    );
  }

  Widget _buildDivider() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Divider(thickness: 2, color: Colors.grey[300]),
      ),
    );
  }
}