import 'package:flutter/foundation.dart';
import '../api/reminder_api_client.dart';
import '../model/interval_type.dart'; // Correct import
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
    // Assuming the API returns List<Map<String, dynamic>>
    final List<Map<String, dynamic>> data = await _apiClient.getPendingByDevice(deviceId);
    debugPrint('📦 Pending reminders received: ${data.length}');
    // Use the corrected _parseInstance method
    return data.map(_parseInstance).where((instance) => instance != null).cast<ReminderInstance>().toList();
  }

  Future<List<ReminderInstance>> getRemindersByTask(int taskId, {bool? completed}) async {
    // Assuming the API returns List<Map<String, dynamic>>
    final List<Map<String, dynamic>> data = await _apiClient.getByTask(taskId, completed: completed);
    debugPrint('📦 Reminders by task received: ${data.length}');
    // Use the corrected _parseInstance method
    return data.map(_parseInstance).where((instance) => instance != null).cast<ReminderInstance>().toList();
  }

  // --- CORRECTED PARSING METHOD ---
  ReminderInstance? _parseInstance(Map<String, dynamic> json) {
    // Correctly parse IntervalType
    final recurrenceTypeStr = (json['taskType'] as String?)?.toLowerCase(); // Use 'taskType' based on ReminderInstance.fromJson
    IntervalType type;
    if (recurrenceTypeStr != null) {
      try {
        type = IntervalType.values.byName(recurrenceTypeStr);
      } catch (_) {
        debugPrint('⚠️ Warning: Unknown IntervalType string "$recurrenceTypeStr" in ReminderInstance JSON. Defaulting to simple.');
        type = IntervalType.simple; // Fallback
      }
    } else {
      debugPrint('⚠️ Warning: Missing "taskType" in ReminderInstance JSON. Defaulting to simple.');
      type = IntervalType.simple; // Fallback if key is missing
    }


    // Parse remindedAt
    DateTime remindedAt;
    final remindedAtStr = json['remindedAt'] as String?;
    if (remindedAtStr != null) {
      try {
        // Parse and convert to local time zone
        remindedAt = DateTime.parse(remindedAtStr).toLocal();
      } catch (e) {
        debugPrint('❌ Error parsing remindedAt "$remindedAtStr": $e. Using current time.');
        remindedAt = DateTime.now(); // Fallback on error
      }
    } else {
      debugPrint('⚠️ Warning: Missing "remindedAt" in ReminderInstance JSON. Using current time.');
      remindedAt = DateTime.now(); // Fallback if key is missing
    }

    // --- CORRECTED: Parse required taskId ---
    final int? taskId = json['taskId'] as int?;
    if (taskId == null) {
      // taskId is essential, cannot create a valid ReminderInstance without it.
      debugPrint('❌ Error: Missing required field "taskId" in ReminderInstance JSON. Skipping instance creation.');
      return null; // Return null to indicate failure
    }
    // --- End Correction ---

    // Parse other fields with null checks and defaults
    final int id = json['id'] as int? ?? 0; // Provide default if null
    final String taskText = (json['taskText'] as String?) ?? 'Untitled';
    final bool isCompleted = (json['isCompleted'] as bool?) ?? false;

    // Construct ReminderInstance using all required parameters
    return ReminderInstance(
      id: id,
      taskText: taskText,
      remindedAt: remindedAt,
      taskType: type,
      isCompleted: isCompleted,
      taskId: taskId, // Pass the required taskId
    );
  }
}