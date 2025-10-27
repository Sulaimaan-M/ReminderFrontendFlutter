import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'todo_list_screen.dart';
import 'create_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = '${_getMonthName(now.month)} ${now.day}, ${now.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'To-Do'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TaskListScreen(),
          TodoListScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTaskScreen(),
            ),
          );
          if (result != null) {
            // Handle result
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
}