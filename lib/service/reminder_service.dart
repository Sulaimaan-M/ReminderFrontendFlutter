import 'package:flutter/foundation.dart';
import '../model/reminder.dart';
import '../api/reminder_api_client.dart';
import 'device_token_service.dart';

class ReminderService {
  final ReminderApiClient _apiClient;

  ReminderService({ReminderApiClient? apiClient})
      : _apiClient = apiClient ?? HttpReminderApiClient();

  Future<int?> getDeviceId() async {
    return await DeviceTokenService().getDeviceId();
  }

  Future<List<Reminder>> getReminders() async {
    final deviceId = await getDeviceId();
    if (deviceId == null) return [];
    return _apiClient.getReminders(deviceId);
  }

  Future<Reminder?> createReminder(Reminder reminder) async {
    final deviceId = await getDeviceId();
    if (deviceId == null) return null;
    final reminderWithDeviceId = Reminder(
      reminderTxt: reminder.reminderTxt,
      remindAt: reminder.remindAt,
      interval: reminder.interval,
      deviceId: deviceId,
    );
    _logRequest('CREATE', reminderWithDeviceId);
    return _apiClient.createReminder(reminderWithDeviceId);
  }

  Future<Reminder?> editReminder(Reminder reminder) async {
    if (reminder.id == null) return null;
    final deviceId = await getDeviceId();
    if (deviceId == null) return null;
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