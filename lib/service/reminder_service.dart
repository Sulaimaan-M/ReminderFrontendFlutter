// lib/service/reminder_service.dart

import 'package:flutter/foundation.dart';
import '../model/reminder.dart';
import '../api/reminder_api_client.dart';
import 'device_token_service.dart'; // 👈 to get deviceId

class ReminderService {
  final ReminderApiClient _apiClient;

  ReminderService({ReminderApiClient? apiClient})
      : _apiClient = apiClient ?? HttpReminderApiClient(); // 👈 NOW DEFAULTS TO REAL CLIENT!

  Future<int?> _getDeviceId() async {
    return await DeviceTokenService().getDeviceId();
  }

  Future<List<Reminder>> getReminders() async {
    final deviceId = await _getDeviceId();
    if (deviceId == null) return [];
    return _apiClient.getReminders(deviceId);
  }

  Future<bool> createReminder(Reminder reminder) async {
    final deviceId = await _getDeviceId();
    if (deviceId == null) return false;
    final reminderWithDeviceId = Reminder(
      reminderTxt: reminder.reminderTxt,
      remindAt: reminder.remindAt,
      interval: reminder.interval,
      deviceId: deviceId,
    );
    _logRequest('CREATE', reminderWithDeviceId);
    return _apiClient.createReminder(reminderWithDeviceId);
  }

  Future<bool> editReminder(Reminder reminder) async {
    if (reminder.id == null) return false;
    final deviceId = await _getDeviceId();
    if (deviceId == null) return false;
    final reminderWithDeviceId = Reminder(
      id: reminder.id,
      reminderTxt: reminder.reminderTxt,
      remindAt: reminder.remindAt,
      interval: reminder.interval,
      deviceId: deviceId,
    );
    _logRequest('EDIT', reminderWithDeviceId);
    return _apiClient.editReminder(reminderWithDeviceId);
  }

  Future<bool> deleteReminder(int id) async {
    return _apiClient.deleteReminder(id);
  }

  void _logRequest(String operation, Reminder reminder) {
    final timestamp = DateTime.now().toIso8601String();
    final json = reminder.toJson();
    debugPrint('''
══════════════════════════════════════════════════════════════════════
$operation REMINDER REQUEST
Timestamp: $timestamp
Data:
  id:          ${reminder.id}
  reminderTxt: ${json['reminderTxt']}
  remindAt:    ${json['remindAt']}
  interval:    ${json['interval']}
  deviceId:    ${json['deviceTokenId']}
══════════════════════════════════════════════════════════════════════
''');
  }
}