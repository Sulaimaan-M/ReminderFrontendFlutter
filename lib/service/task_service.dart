import 'package:flutter/foundation.dart';
import '../model/interval_type.dart';
import '../model/task_creation_data.dart';
import '../model/task.dart';
import '../model/recurring_task.dart';
import '../model/simple_task.dart';
import '../api/task_api_client.dart';
import 'device_token_service.dart';
import '../util/timezone_helper.dart';

class TaskService {
  final TaskApiClient _apiClient;

  TaskService({TaskApiClient? apiClient})
      : _apiClient = apiClient ?? HttpTaskApiClient();

  Future<int?> getDeviceId() async => DeviceTokenService().getDeviceId();

  Future<List<Task>> getTasks() async {
    final deviceId = await getDeviceId();
    debugPrint('🔎 TaskService.getTasks | deviceId=$deviceId');
    if (deviceId == null) {
      debugPrint('❌ TaskService.getTasks | no device id');
      return [];
    }

    // Fetch both recurring and simple tasks
    final recurringTasksData = await _apiClient.getRecurringTasksByDevice(deviceId);
    final simpleTasksData = await _apiClient.getSimpleTasksByDevice(deviceId);

    debugPrint('📦 TaskService.getTasks | recurring: ${recurringTasksData.length}, simple: ${simpleTasksData.length}');

    // Convert recurring tasks
    final recurringTasks = recurringTasksData.map((data) {
      return RecurringTask.fromJson(data);
    }).toList();

    // Convert simple tasks
    final simpleTasks = simpleTasksData.map((data) {
      return SimpleTask.fromJson(data);
    }).toList();

    // Convert to unified Task model
    final List<Task> tasks = [];

    // Add recurring tasks
    for (var recurringTask in recurringTasks) {
      tasks.add(Task(
        id: recurringTask.id,
        taskText: recurringTask.taskTxt,
        createdAt: DateTime.now(), // Backend doesn't send this, so use current time
        nextReminderAt: recurringTask.nextReminderAt,
        cronExpression: '', // Backend doesn't send this in recurring task response
        interval: _stringToIntervalType(recurringTask.recurrenceType),
        deviceId: deviceId,
      ));
    }

    // Add simple tasks
    for (var simpleTask in simpleTasks) {
      tasks.add(Task(
        id: simpleTask.id,
        taskText: simpleTask.taskTxt,
        createdAt: DateTime.now(), // Backend doesn't send this, so use current time
        nextReminderAt: simpleTask.nextReminderAt,
        cronExpression: '', // Backend doesn't send this in simple task response
        interval: IntervalType.simple,
        deviceId: deviceId,
      ));
    }

    return tasks;
  }

  Future<bool> createTask({
    required String taskText,
    required int hour,
    required int minute,
    required IntervalType recurrenceType,
    DateTime? simpleDate,
    List<int>? weeklyDays,
    int? monthlySingleDay,
    int? monthlyRangeStart,
    int? monthlyRangeEnd,
    int? yearlyMonth,
    int? yearlyDay,
  }) async {
    final deviceId = await getDeviceId();
    if (deviceId == null) return false;

    final timeDetail = TimeDetail(
      seconds: 0,
      minutes: minute,
      hours: hour,
      timezone: getDeviceTimezone(),
    );

    final recurrencePattern = _buildRecurrencePattern(
      recurrenceType: recurrenceType,
      simpleDate: simpleDate,
      weeklyDays: weeklyDays,
      monthlySingleDay: monthlySingleDay,
      monthlyRangeStart: monthlyRangeStart,
      monthlyRangeEnd: monthlyRangeEnd,
      yearlyMonth: yearlyMonth,
      yearlyDay: yearlyDay,
    );

    final payload = TaskCreationData(
      taskText: taskText,
      deviceId: deviceId,
      recurrenceType: recurrenceType,
      timeDetail: timeDetail,
      recurrencePattern: recurrencePattern,
    );

    final res = await _apiClient.createTask(payload);
    final ok = res != null;
    debugPrint('✅ TaskService.createTask | success=$ok');
    return ok;
  }

  Future<bool> updateTask({
    required int taskId,
    required String taskText,
    required int hour,
    required int minute,
    required IntervalType recurrenceType,
    DateTime? simpleDate,
    List<int>? weeklyDays,
    int? monthlySingleDay,
    int? monthlyRangeStart,
    int? monthlyRangeEnd,
    int? yearlyMonth,
    int? yearlyDay,
  }) async {
    final deviceId = await getDeviceId();
    if (deviceId == null) return false;

    final timeDetail = TimeDetail(
      seconds: 0,
      minutes: minute,
      hours: hour,
      timezone: getDeviceTimezone(),
    );

    final recurrencePattern = _buildRecurrencePattern(
      recurrenceType: recurrenceType,
      simpleDate: simpleDate,
      weeklyDays: weeklyDays,
      monthlySingleDay: monthlySingleDay,
      monthlyRangeStart: monthlyRangeStart,
      monthlyRangeEnd: monthlyRangeEnd,
      yearlyMonth: yearlyMonth,
      yearlyDay: yearlyDay,
    );

    final payload = TaskCreationData(
      taskText: taskText,
      deviceId: deviceId,
      recurrenceType: recurrenceType,
      timeDetail: timeDetail,
      recurrencePattern: recurrencePattern,
    );

    final ok = await _apiClient.updateTask(taskId, payload);
    debugPrint('✅ TaskService.updateTask | id=$taskId success=$ok');
    return ok;
  }

  Future<bool> deleteTask(int taskId) async {
    final ok = await _apiClient.deleteTask(taskId);
    debugPrint('✅ TaskService.deleteTask | id=$taskId success=$ok');
    return ok;
  }

  RecurrencePattern _buildRecurrencePattern({
    required IntervalType recurrenceType,
    DateTime? simpleDate,
    List<int>? weeklyDays,
    int? monthlySingleDay,
    int? monthlyRangeStart,
    int? monthlyRangeEnd,
    int? yearlyMonth,
    int? yearlyDay,
  }) {
    switch (recurrenceType) {
      case IntervalType.simple:
        return RecurrencePattern(
          dayOfMonth: simpleDate?.day.toString() ?? '1',
          month: simpleDate?.month.toString() ?? '1',
          year: simpleDate?.year.toString() ?? '2025',
          dayOfWeek: '?',
        );
      case IntervalType.daily:
        return RecurrencePattern(
          dayOfMonth: '*',
          month: '*',
          year: '*',
          dayOfWeek: '?',
        );
      case IntervalType.weekly:
        final dayNames = _convertWeekdayIndicesToNames(weeklyDays ?? []);
        return RecurrencePattern(
          dayOfMonth: '?',
          month: '*',
          year: '*',
          dayOfWeek: dayNames,
        );
      case IntervalType.monthly:
        String dayOfMonth;
        if (monthlyRangeStart != null && monthlyRangeEnd != null) {
          dayOfMonth = '$monthlyRangeStart-$monthlyRangeEnd';
        } else {
          dayOfMonth = monthlySingleDay?.toString() ?? '1';
        }
        return RecurrencePattern(
          dayOfMonth: dayOfMonth,
          month: '*',
          year: '*',
          dayOfWeek: '?',
        );
      case IntervalType.yearly:
        return RecurrencePattern(
          dayOfMonth: yearlyDay?.toString() ?? '1',
          month: yearlyMonth?.toString() ?? '1',
          year: '*',
          dayOfWeek: '?',
        );
    }
  }

  String _convertWeekdayIndicesToNames(List<int> indices) {
    const dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    if (indices.isEmpty) return 'MON';
    return indices.map((i) => dayNames[i]).join(',');
  }

  IntervalType _stringToIntervalType(String type) {
    switch (type.toUpperCase()) {
      case 'DAILY':
        return IntervalType.daily;
      case 'WEEKLY':
        return IntervalType.weekly;
      case 'MONTHLY':
        return IntervalType.monthly;
      case 'YEARLY':
        return IntervalType.yearly;
      case 'SIMPLE':
      default:
        return IntervalType.simple;
    }
  }
}