import 'package:flutter/foundation.dart';
import '../api/reminder_api_client.dart';
import '../model/interval_type.dart';
import '../model/detailed_reminder.dart';
import '../model/minimal_reminder.dart'; // NEW: Import for reminder history
import 'device_token_service.dart';

class ReminderService {
  final ReminderApiClient _apiClient;

  ReminderService({ReminderApiClient? apiClient})
      : _apiClient = apiClient ?? HttpReminderApiClient();

  Future<int?> getDeviceId() async => DeviceTokenService().getDeviceId();

  Future<List<DetailedReminder>> getPendingReminders() async {
    final deviceId = await getDeviceId();
    if (deviceId == null) {
      debugPrint('❌ No device ID found for getPendingReminders');
      return [];
    }

    final List<Map<String, dynamic>> rawData = await _apiClient.getPendingByDevice(deviceId);
    debugPrint('📦 Pending reminders received: ${rawData.length}');

    return rawData.map(_parseDetailedReminder).whereType<DetailedReminder>().toList();
  }

  // NEW: Get reminders by task ID for ViewTaskScreen
  Future<List<MinimalReminder>> getRemindersByTask(int taskId) async {
    debugPrint('📤 ReminderService.getRemindersByTask | taskId=$taskId');

    try {
      final List<Map<String, dynamic>> rawData = await _apiClient.getRemindersByTask(taskId);
      debugPrint('📦 Reminders by task received: ${rawData.length}');

      return rawData.map(_parseMinimalReminder).whereType<MinimalReminder>().toList();
    } catch (e) {
      debugPrint('❌ ReminderService.getRemindersByTask | Error: $e');
      return [];
    }
  }

  DetailedReminder? _parseDetailedReminder(Map<String, dynamic> json) {
    try {
      return DetailedReminder.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error parsing DetailedReminder: $e');
      return null;
    }
  }

  // NEW: Parse raw data to MinimalReminder for reminder history
  MinimalReminder? _parseMinimalReminder(Map<String, dynamic> json) {
    try {
      // Parse the reminder data - adjust field names based on your backend response
      final int id = json['reminderId'] as int? ?? json['id'] as int? ?? 0;
      final String remindedAtStr = json['remindedAt'] as String? ?? DateTime.now().toIso8601String();
      final bool isCompleted = json['isCompleted'] as bool? ?? false;

      return MinimalReminder(
        id: id,
        remindedAt: DateTime.parse(remindedAtStr),
        isCompleted: isCompleted,
      );
    } catch (e) {
      debugPrint('❌ Error parsing MinimalReminder: $e');
      return null;
    }
  }

  Future<bool> completeReminder(int reminderId) async {
    debugPrint('🔔 ReminderService.completeReminder | reminderId=$reminderId');
    try {
      final success = await _apiClient.completeReminder(reminderId);
      debugPrint('✅ ReminderService.completeReminder | success=$success');
      return success;
    } catch (e) {
      debugPrint('❌ ReminderService.completeReminder | Error: $e');
      return false;
    }
  }
}