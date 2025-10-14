// lib/service/reminder_service.dart

import 'package:flutter/foundation.dart'; // for debugPrint
import '../model/reminder.dart';
import '../api/reminder_api_client.dart';

class ReminderService {
  final ReminderApiClient _apiClient;

  ReminderService({ReminderApiClient? apiClient})
      : _apiClient = apiClient ?? DummyReminderApiClient();

  Future<List<Reminder>> getReminders() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return [
      Reminder(reminderTxt: 'Buy groceries', remindAt: now.add(const Duration(hours: 1)), interval: IntervalType.simple),
      Reminder(reminderTxt: 'Team sync', remindAt: now.add(const Duration(hours: 3)), interval: IntervalType.daily),
    ];
  }

  Future<bool> createReminder(Reminder reminder) async {
    _logRequest('CREATE', reminder);
    return _apiClient.createReminder(reminder);
  }

  Future<bool> editReminder(Reminder reminder) async {
    _logRequest('EDIT', reminder);
    return _apiClient.editReminder(reminder);
  }

  // ✅ NEW: Log request details
  void _logRequest(String operation, Reminder reminder) {
    final timestamp = DateTime.now().toIso8601String();
    final json = reminder.toJson();
    debugPrint('''
══════════════════════════════════════════════════════════════════════
$operation REMINDER REQUEST
Timestamp: $timestamp
Data:
  reminderTxt: ${json['reminderTxt']}
  remindAt:    ${json['remindAt']}
  interval:    ${json['interval']}
══════════════════════════════════════════════════════════════════════
''');
  }
}