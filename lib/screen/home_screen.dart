import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'todo_list_screen.dart';
import 'create_task_screen.dart';
import 'package:reminder_app/util/route_observer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;

  final GlobalKey<TaskListScreenState> _taskKey = GlobalKey<TaskListScreenState>();
  final GlobalKey<TodoListScreenState> _todoKey = GlobalKey<TodoListScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Coming back from another screen: refresh both tabs
    _taskKey.currentState?.reload();
    _todoKey.currentState?.reload();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // Switching tabs: refresh only active tab
    if (_tabController.index == 0) {
      _taskKey.currentState?.reload();
    } else {
      _todoKey.currentState?.reload();
    }
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
        children: [
          TaskListScreen(key: _taskKey),
          TodoListScreen(key: _todoKey),
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
          if (result == true) {
            _taskKey.currentState?.reload();
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