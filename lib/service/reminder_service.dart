import 'package:flutter/foundation.dart';
import '../api/reminder_api_client.dart';
import '../model/interval_type.dart';
import 'device_token_service.dart';
import '../model/reminder_instance.dart';

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
    final List<Map<String, dynamic>> data = await _apiClient.getPendingByDevice(deviceId);
    debugPrint('📦 Pending reminders received: ${data.length}');
    return data.map(_parseInstance).where((instance) => instance != null).cast<ReminderInstance>().toList();
  }

  // Add this missing method
  Future<List<ReminderInstance>> getRemindersByTask(int taskId) async {
    // Since your backend doesn't have this endpoint, we'll need to implement a workaround
    // For now, we'll return an empty list and you can implement the backend endpoint later
    debugPrint('⚠️ getRemindersByTask not implemented in backend. Returning empty list.');
    return [];

    // When you implement the backend endpoint, it would look like this:
    /*
    final List<Map<String, dynamic>> data = await _apiClient.getByTask(taskId);
    debugPrint('📦 Reminders by task received: ${data.length}');
    return data.map(_parseInstance).where((instance) => instance != null).cast<ReminderInstance>().toList();
    */
  }

  ReminderInstance? _parseInstance(Map<String, dynamic> json) {
    // Correctly parse IntervalType
    final recurrenceTypeStr = (json['recurrenceType'] as String?)?.toLowerCase();
    IntervalType type;
    if (recurrenceTypeStr != null) {
      try {
        type = IntervalType.values.byName(recurrenceTypeStr);
      } catch (_) {
        debugPrint('⚠️ Warning: Unknown IntervalType string "$recurrenceTypeStr" in ReminderInstance JSON. Defaulting to simple.');
        type = IntervalType.simple;
      }
    } else {
      debugPrint('⚠️ Warning: Missing "recurrenceType" in ReminderInstance JSON. Defaulting to simple.');
      type = IntervalType.simple;
    }

    // Parse remindedAt
    DateTime remindedAt;
    final remindedAtStr = json['remindedAt'] as String?;
    if (remindedAtStr != null) {
      try {
        remindedAt = DateTime.parse(remindedAtStr).toLocal();
      } catch (e) {
        debugPrint('❌ Error parsing remindedAt "$remindedAtStr": $e. Using current time.');
        remindedAt = DateTime.now();
      }
    } else {
      debugPrint('⚠️ Warning: Missing "remindedAt" in ReminderInstance JSON. Using current time.');
      remindedAt = DateTime.now();
    }

    // Parse required taskId
    final int? taskId = json['taskId'] as int?;
    if (taskId == null) {
      debugPrint('❌ Error: Missing required field "taskId" in ReminderInstance JSON. Skipping instance creation.');
      return null;
    }

    // Parse other fields with null checks and defaults
    final int id = json['reminderId'] as int? ?? 0; // Use reminderId from backend
    final String taskText = (json['taskTxt'] as String?) ?? 'Untitled';
    final bool isCompleted = (json['isCompleted'] as bool?) ?? false;

    // Construct ReminderInstance using all required parameters
    return ReminderInstance(
      id: id,
      taskText: taskText,
      remindedAt: remindedAt,
      taskType: type,
      isCompleted: isCompleted,
      taskId: taskId,
    );
  }
}