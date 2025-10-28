import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://10.0.2.2:8080';

abstract class ReminderApiClient {
  Future<List<Map<String, dynamic>>> getPendingByDevice(int deviceId);
  Future<bool> completeReminder(int reminderId); // NEW METHOD
}

class HttpReminderApiClient implements ReminderApiClient {
  final http.Client _client = http.Client();

  @override
  Future<List<Map<String, dynamic>>> getPendingByDevice(int deviceId) async {
    try {
      debugPrint('📤 GET PENDING REMINDERS FOR DEVICE: $deviceId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/reminder/device/$deviceId/pending'),
      );

      _logResponse('GET PENDING REMINDERS', response);

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        if (responseBody is List) {
          debugPrint('✅ GET PENDING REMINDERS BODY: $responseBody');
          return responseBody.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('💥 GET PENDING REMINDERS ERROR: $e');
      return [];
    }
  }

  @override
  Future<bool> completeReminder(int reminderId) async {
    try {
      debugPrint('✅ COMPLETE REMINDER: $reminderId');

      final response = await _client.put(
        Uri.parse('$_baseUrl/reminder/$reminderId/complete'),
        headers: {'Content-Type': 'application/json'},
      );

      _logResponse('COMPLETE REMINDER', response);

      // Return true for success (204 No Content) or if already completed (200)
      if (response.statusCode == 204 || response.statusCode == 200) {
        debugPrint('✅ COMPLETE REMINDER SUCCESS: $reminderId');
        return true;
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ COMPLETE REMINDER NOT FOUND: $reminderId');
        return false;
      } else {
        debugPrint('❌ COMPLETE REMINDER FAILED: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('💥 COMPLETE REMINDER ERROR: $e');
      return false;
    }
  }

  void _logResponse(String operation, http.Response response) {
    debugPrint('''
══════════════════════════════════════════════════════════════════════
$operation RESPONSE
Status Code: ${response.statusCode}
Headers: ${response.headers}
Body: ${response.body}
══════════════════════════════════════════════════════════════════════
''');
  }
}