import 'package:flutter/foundation.dart';
import '../api/reminder_api_client.dart';
import '../model/interval_type.dart';
import '../model/detailed_reminder.dart'; // NEW: Import DetailedReminder
import 'device_token_service.dart';

class ReminderService {
  final ReminderApiClient _apiClient;

  ReminderService({ReminderApiClient? apiClient})
      : _apiClient = apiClient ?? HttpReminderApiClient();

  Future<int?> getDeviceId() async => DeviceTokenService().getDeviceId();

  // UPDATED: Return List<DetailedReminder> instead of List<ReminderInstance>
  Future<List<DetailedReminder>> getPendingReminders() async {
    final deviceId = await getDeviceId();
    if (deviceId == null) {
      debugPrint('❌ No device ID found for getPendingReminders');
      return [];
    }

    // Get raw data from API
    final List<Map<String, dynamic>> rawData = await _apiClient.getPendingByDevice(deviceId);
    debugPrint('📦 Pending reminders received: ${rawData.length}');

    // Convert raw data to DetailedReminder objects
    return rawData.map(_parseDetailedReminder).whereType<DetailedReminder>().toList();
  }

  // NEW: Parse raw data directly to DetailedReminder
  DetailedReminder? _parseDetailedReminder(Map<String, dynamic> json) {
    try {
      return DetailedReminder.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error parsing DetailedReminder: $e');
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