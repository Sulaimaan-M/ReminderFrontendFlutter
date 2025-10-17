import 'package:flutter/material.dart';
import 'package:reminder_app/screen/view_reminder_screen.dart';
import '../model/reminder.dart';
import '../service/reminder_service.dart';
import 'create_reminder_screen.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final service = ReminderService();
    final reminders = await service.getReminders();
    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = '${_getMonthName(now.month)} ${now.day}, ${now.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
          ? const Center(child: Text('No reminders yet.'))
          : ListView.builder(
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
                  // Deleted: remove by ID
                  setState(() {
                    _reminders.removeWhere((rem) => rem.id == result);
                  });
                } else if (result is Reminder) {
                  // Edited: replace
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateReminderScreen(),
            ),
          );
          if (result is Reminder) {
            setState(() {
              _reminders.insert(0, result);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }

  String _formatDateTime(DateTime dt) {
    final date = '${dt.month}/${dt.day}/${dt.year}';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$date at $hour:$minute $ampm';
  }
}