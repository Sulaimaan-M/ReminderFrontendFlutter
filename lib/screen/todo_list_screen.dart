import 'package:flutter/material.dart';
import '../model/reminder.dart';
import '../model/reminder_instance.dart';
import '../service/reminder_service.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => TodoListScreenState();
}

class TodoListScreenState extends State<TodoListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Top section (Simple Tasks) remains dummy for now
  List<Reminder> _simpleTasks = [
    Reminder(
      id: 1,
      reminderTxt: 'Doctor appointment',
      remindAt: DateTime(2025, 10, 28, 15, 30),
      interval: IntervalType.simple,
      deviceId: 1,
    ),
  ];

  // Bottom section (Reminders) - now fetched from backend
  List<ReminderInstance> _reminderInstances = [];
  bool _loadingReminders = true;
  String? _errorReminders;

  @override
  void initState() {
    super.initState();
    _loadPendingReminders();
  }

  Future<void> reload() async {
    // Simple tasks remain dummy
    await _loadPendingReminders();
  }

  Future<void> _loadPendingReminders() async {
    setState(() {
      _loadingReminders = true;
      _errorReminders = null;
    });

    try {
      final service = ReminderService();
      final list = await service.getPendingReminders();
      if (!mounted) return;
      setState(() {
        _reminderInstances = list;
        _loadingReminders = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingReminders = false;
        _errorReminders = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        // Simple Tasks (top; still dummy)
        _header(context, 'Simple Tasks'),
        _simpleTasks.isEmpty
            ? _emptyText('No simple tasks')
            : SliverList.builder(
          itemCount: _simpleTasks.length,
          itemBuilder: (context, index) {
            final task = _simpleTasks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(task.reminderTxt),
                subtitle: Text(_formatDateTime(task.remindAt)),
              ),
            );
          },
        ),

        _divider(),

        // Reminders (bottom; fetched)
        _header(context, 'Reminders'),
        if (_loadingReminders)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          )
        else if (_errorReminders != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text('Failed to load reminders: $_errorReminders'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _loadPendingReminders,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_reminderInstances.isEmpty)
            _emptyText('No reminders')
          else
            SliverList.builder(
              itemCount: _reminderInstances.length,
              itemBuilder: (context, index) {
                final inst = _reminderInstances[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(inst.taskText),
                    subtitle: Text('Reminded at: ${_formatDateTime(inst.remindedAt)}'),
                    // Show a gray circle for incomplete (these are all incomplete)
                    trailing: Icon(
                      inst.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: inst.isCompleted ? Colors.green : Colors.grey,
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }

  SliverToBoxAdapter _header(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style:
          Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverToBoxAdapter _emptyText(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(text, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  SliverToBoxAdapter _divider() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Divider(thickness: 2, color: Colors.grey[300]),
      ),
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