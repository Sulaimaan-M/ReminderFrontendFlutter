import 'package:flutter/foundation.dart';
import '../api/reminder_api_client.dart';
import 'device_token_service.dart';
import '../model/reminder_instance.dart';
import '../model/reminder.dart';

class ReminderService {
  final ReminderApiClient _apiClient;

  ReminderService({ReminderApiClient? apiClient})
      : _apiClient = apiClient ?? HttpReminderApiClient();

  Future<int?> getDeviceId() async => DeviceTokenService().getDeviceId();

  Future<List<ReminderInstance>> getPendingReminders() async {
    final deviceId = await getDeviceId();
    if (deviceId == null) {
      debugPrint('❌ No device ID found for getPendingReminders');
      return [];
    }
    final data = await _apiClient.getPendingByDevice(deviceId);
    debugPrint('📦 Pending reminders received: ${data.length}');
    return data.map(_parseInstance).toList();
  }

  // NEW: fetch all instances for a task (optionally filtered)
  Future<List<ReminderInstance>> getRemindersByTask(int taskId, {bool? completed}) async {
    final data = await _apiClient.getByTask(taskId, completed: completed);
    debugPrint('📦 Reminders by task received: ${data.length}');
    return data.map(_parseInstance).toList();
  }

  ReminderInstance _parseInstance(Map<String, dynamic> json) {
    final recurrenceTypeStr = json['recurrenceType'] as String?;
    final type = IntervalType.fromString(recurrenceTypeStr);

    DateTime remindedAt;
    final remindedAtStr = json['remindedAt'] as String?;
    if (remindedAtStr != null) {
      try {
        remindedAt = DateTime.parse(remindedAtStr).toLocal();
      } catch (_) {
        remindedAt = DateTime.now();
      }
    } else {
      remindedAt = DateTime.now();
    }

    return ReminderInstance(
      id: (json['id'] as num).toInt(),
      taskText: (json['taskText'] as String?) ?? 'Untitled',
      remindedAt: remindedAt,
      taskType: type,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
    );
  }
}