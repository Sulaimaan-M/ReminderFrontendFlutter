// lib/api/reminder_api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/reminder.dart';

//const String _baseUrl = 'http://10.0.2.8080'; // Wait — you had 10.0.2.2:8080

// 🔹 CORRECT BASE URL (Android emulator)
const String _baseUrl = 'http://10.0.2.2:8080';

abstract class ReminderApiClient {
  Future<bool> createReminder(Reminder reminder);
  Future<bool> editReminder(Reminder reminder);
  Future<bool> deleteReminder(int id); // 👈 NEW
  Future<List<Reminder>> getReminders(int deviceId); // 👈 NEW
}

class HttpReminderApiClient implements ReminderApiClient {
  final http.Client _client = http.Client();

  @override
  Future<bool> createReminder(Reminder reminder) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/reminder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reminder.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> editReminder(Reminder reminder) async {
    if (reminder.id == null) return false; // Can't edit without ID
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/reminder/${reminder.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reminder.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteReminder(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/reminder/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Reminder>> getReminders(int deviceId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/reminder/$deviceId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Reminder.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

// Keep Dummy client for testing if needed
class DummyReminderApiClient implements ReminderApiClient {
  @override
  Future<bool> createReminder(Reminder reminder) async => true;
  @override
  Future<bool> editReminder(Reminder reminder) async => true;
  @override
  Future<bool> deleteReminder(int id) async => true;
  @override
  Future<List<Reminder>> getReminders(int deviceId) async => [];
}