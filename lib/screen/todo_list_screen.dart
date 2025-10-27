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
      remindAt: DateTime(2025, 10, 28, 15, 30), // Example time
      interval: IntervalType.simple,
      deviceId: 1,
    ),
    Reminder( // Added another example
      id: 2,
      reminderTxt: 'Buy groceries',
      remindAt: DateTime.now().add(const Duration(hours: 2)), // Example time
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
    // TODO: Implement fetching actual SIMPLE tasks from backend
    _loadPendingReminders();
  }

  Future<void> reload() async {
    // TODO: Implement fetching actual SIMPLE tasks from backend
    await _loadPendingReminders();
  }

  Future<void> _loadPendingReminders() async {
    if (!mounted) return; // Check mounted at the beginning
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

    return RefreshIndicator( // Added RefreshIndicator for pull-to-refresh
      onRefresh: reload,
      child: CustomScrollView(
        slivers: [
          // Simple Tasks (top; still dummy, needs backend integration)
          _header(context, 'One-Time Tasks'), // Renamed header
          if (_loadingReminders) // Show loading shimmer or similar for simple tasks too if fetched
            SliverToBoxAdapter(child: Container()) // Placeholder for loading state
          else if (_simpleTasks.isEmpty)
            _emptyText('No one-time tasks scheduled') // Updated empty text
          else
            SliverList.builder(
              itemCount: _simpleTasks.length,
              itemBuilder: (context, index) {
                final task = _simpleTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Consistent margin
                  child: ListTile(
                    leading: Icon(Icons.event_available_outlined, color: Colors.orange[700]), // Themed icon
                    title: Text(task.reminderTxt),
                    subtitle: Text(_formatDateTime(task.remindAt)), // Use updated format
                    trailing: IconButton( // Added button to mark complete (dummy action for now)
                      icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
                      tooltip: 'Mark as done (Not Implemented)',
                      onPressed: () {
                        // TODO: API Call to complete SIMPLE task by ID
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Complete Simple Task API not implemented.')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

          _divider(),

          // Reminders (bottom; fetched recurring instances)
          _header(context, 'Upcoming Reminders'), // Renamed header
          if (_loadingReminders)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0), // Increased padding
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
          else if (_errorReminders != null)
            SliverToBoxAdapter( // Wrap error in SliverToBoxAdapter
              child: _buildErrorWidget(_errorReminders!, _loadPendingReminders),
            )
          else if (_reminderInstances.isEmpty)
              _emptyText('No upcoming reminders') // Updated empty text
            else
              SliverList.builder(
                itemCount: _reminderInstances.length,
                itemBuilder: (context, index) {
                  final inst = _reminderInstances[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Consistent margin
                    child: ListTile(
                      leading: Icon(Icons.notifications_active_outlined, color: Colors.blue[700]), // Themed icon
                      title: Text(inst.taskText),
                      subtitle: Text('Due at: ${_formatDateTime(inst.remindedAt)}'), // Use updated format
                      // TODO: Implement API to mark reminder instance complete
                      trailing: IconButton(
                        icon: Icon(
                          inst.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: inst.isCompleted ? Colors.green : Colors.grey,
                        ),
                        tooltip: inst.isCompleted ? 'Completed' : 'Mark as done (Not Implemented)',
                        onPressed: inst.isCompleted ? null : () { // Disable if already complete visually
                          // TODO: API Call to complete instance by ID
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Complete Reminder Instance API not implemented.')),
                          );
                          // Optimistic UI update (remove if API call fails)
                          // setState(() {
                          //   inst.isCompleted = true;
                          // });
                        },
                      ),
                    ),
                  );
                },
              ),

          // Add some bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _header(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0), // Adjusted padding
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith( // Adjusted style
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
          Text(
            'Failed to load reminders',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMsg, // Show specific error
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _emptyText(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0), // Added vertical padding
        child: Center( // Center the text
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 16), // Adjusted style
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _divider() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), // Added horizontal padding
        child: Divider(thickness: 1, color: Colors.grey[300]), // Adjusted thickness
      ),
    );
  }

  // --- Updated Formatting Function ---
  String _formatDateTime(DateTime dt) {
    // 1. Convert the DateTime object to the device's local time zone.
    final localDt = dt.toLocal();

    // 2. Format the localDt object.
    final date = '${localDt.month}/${localDt.day}/${localDt.year}';
    final hour = localDt.hour % 12 == 0 ? 12 : localDt.hour % 12;
    final minute = localDt.minute.toString().padLeft(2, '0');
    final ampm = localDt.hour < 12 ? 'AM' : 'PM';
    return '$date at $hour:$minute $ampm';
  }
// --- End Updated Formatting Function ---
}