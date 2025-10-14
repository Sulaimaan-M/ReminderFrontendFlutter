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
  late Future<List<Reminder>> _futureReminders;

  @override
  void initState() {
    super.initState();
    _refreshReminders();
  }

  void _refreshReminders() {
    setState(() {
      _futureReminders = ReminderService().getReminders();
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
      body: FutureBuilder<List<Reminder>>(
        future: _futureReminders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reminders = snapshot.data ?? [];
          if (reminders.isEmpty) {
            return const Center(child: Text('No reminders yet.'));
          }
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final r = reminders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(r.reminderTxt),
                  subtitle: Text(
                    '${_formatDateTime(r.remindAt)} • ${r.interval.label}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewReminderScreen(reminder: r),
                      ),
                    );
                  },
                ),
              );
            },
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
          if (result == true) {
            _refreshReminders(); // Refresh list after adding
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