// lib/api/reminder_api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/reminder.dart';

// 🔹 Base URL of your Spring Boot backend
const String _baseUrl = 'http://10.0.2.2:8080'; // Android emulator
// const String _baseUrl = 'http://192.168.x.x:8080'; // Real device (replace with your machine IP)

abstract class ReminderApiClient {
  Future<bool> createReminder(Reminder reminder);
  Future<bool> editReminder(Reminder reminder);
}

// ✅ REAL HTTP CLIENT (NEW)
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
      // In production, log error
      return false;
    } finally {
      // Optional: close client if you manage its lifecycle
      // _client.close();
    }
  }

  @override
  Future<bool> editReminder(Reminder reminder) async {
    // 🔜 TODO: Implement real edit when you have PUT /reminder/{id}
    // For now, reuse create (or return false)
    return createReminder(reminder);
  }
}

// ✅ YOUR EXISTING DUMMY CLIENT (UNCHANGED)
class DummyReminderApiClient implements ReminderApiClient {
  @override
  Future<bool> createReminder(Reminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<bool> editReminder(Reminder reminder) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}