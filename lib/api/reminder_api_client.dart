import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://10.0.2.2:8080';

abstract class ReminderApiClient {
  Future<List<Map<String, dynamic>>> getPendingByDevice(int deviceId);
  Future<List<Map<String, dynamic>>> getByTask(int taskId, {bool? completed}); // NEW
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
  Future<List<Map<String, dynamic>>> getByTask(int taskId, {bool? completed}) async {
    try {
      final uri = completed == null
          ? Uri.parse('$_baseUrl/reminder/task/$taskId')
          : Uri.parse('$_baseUrl/reminder/task/$taskId?completed=$completed');

      debugPrint('📤 GET REMINDERS BY TASK: $uri');

      final response = await _client.get(uri);

      _logResponse('GET REMINDERS BY TASK', response);

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        if (responseBody is List) {
          debugPrint('✅ GET REMINDERS BY TASK BODY: $responseBody');
          return responseBody.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('💥 GET REMINDERS BY TASK ERROR: $e');
      return [];
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