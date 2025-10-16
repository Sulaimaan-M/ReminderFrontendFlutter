// lib/api/reminder_api_client.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../model/reminder.dart';

const String _baseUrl = 'http://10.0.2.2:8080';

abstract class ReminderApiClient {
  Future<Reminder?> createReminder(Reminder reminder);
  Future<Reminder?> editReminder(Reminder reminder);
  Future<bool> deleteReminder(int id);
  Future<List<Reminder>> getReminders(int deviceId);
}

class HttpReminderApiClient implements ReminderApiClient {
  final http.Client _client = http.Client();

  @override
  Future<Reminder?> createReminder(Reminder reminder) async {
    try {
      final requestBody = jsonEncode(reminder.toJson());
      debugPrint('📤 CREATE REQUEST BODY: $requestBody');

      final response = await _client.post(
        Uri.parse('$_baseUrl/reminder'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      _logResponse('CREATE', response);

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        debugPrint('✅ CREATE RESPONSE BODY (RAW): $responseBody');
        if (responseBody is Map<String, dynamic>) {
          return Reminder.fromBackendJson(responseBody);
        } else {
          debugPrint('❌ CREATE: Response is not a JSON object');
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('💥 CREATE ERROR: $e');
      return null;
    }
  }

  @override
  Future<Reminder?> editReminder(Reminder reminder) async {
    if (reminder.id == null) {
      debugPrint('❌ EDIT ERROR: Reminder ID is null');
      return null;
    }

    try {
      final requestBody = jsonEncode(reminder.toJson());
      debugPrint('📤 EDIT REQUEST BODY: $requestBody');

      final response = await _client.put(
        Uri.parse('$_baseUrl/reminder/${reminder.id}'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      _logResponse('EDIT', response);

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        debugPrint('✅ EDIT RESPONSE BODY (RAW): $responseBody');
        if (responseBody is Map<String, dynamic>) {
          return Reminder.fromBackendJson(responseBody);
        } else {
          debugPrint('❌ EDIT: Response is not a JSON object');
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('💥 EDIT ERROR: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteReminder(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/reminder/$id'),
      );
      _logResponse('DELETE', response);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('💥 DELETE ERROR: $e');
      return false;
    }
  }

  @override
  Future<List<Reminder>> getReminders(int deviceId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/reminder/$deviceId'),
      );
      _logResponse('GET LIST', response);

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        debugPrint('✅ GET LIST RESPONSE (RAW): $responseBody');
        if (responseBody is List) {
          return responseBody
              .where((item) => item is Map<String, dynamic>)
              .map((json) => Reminder.fromBackendJson(json))
              .toList();
        } else {
          debugPrint('❌ GET LIST: Response is not a JSON array');
          return [];
        }
      }
      return [];
    } catch (e) {
      debugPrint('💥 GET LIST ERROR: $e');
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

class DummyReminderApiClient implements ReminderApiClient {
  @override
  Future<Reminder?> createReminder(Reminder reminder) async => reminder;

  @override
  Future<Reminder?> editReminder(Reminder reminder) async => reminder;

  @override
  Future<bool> deleteReminder(int id) async => true;

  @override
  Future<List<Reminder>> getReminders(int deviceId) async => [];
}