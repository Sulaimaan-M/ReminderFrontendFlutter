import 'package:flutter/material.dart';
import 'package:reminder_app/screen/view_reminder_screen.dart';
import '../model/reminder.dart';
import '../service/reminder_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with AutomaticKeepAliveClientMixin {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final service = ReminderService();
    final reminders = await service.getReminders();

    final repeatingTasks = reminders.where((r) => r.interval != IntervalType.simple).toList();

    setState(() {
      _reminders = repeatingTasks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reminders.isEmpty) {
      return const Center(child: Text('No repeating tasks yet.'));
    }

    return ListView.builder(
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final r = _reminders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(r.reminderTxt.isNotEmpty ? r.reminderTxt : 'Untitled'),
            subtitle: Text(
              '${_formatDateTime(r.remindAt)} • ${r.interval.label}',
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewReminderScreen(reminder: r),
                ),
              );
              if (result is int) {
                setState(() {
                  _reminders.removeWhere((rem) => rem.id == result);
                });
              } else if (result is Reminder) {
                final index = _reminders.indexWhere((rem) => rem.id == result.id);
                if (index != -1) {
                  setState(() {
                    _reminders[index] = result;
                  });
                }
              }
            },
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final date = '${dt.month}/${dt.day}/${dt.year}';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$date at $hour:$minute $ampm';
  }
}