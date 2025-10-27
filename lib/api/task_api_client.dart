import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../model/task_creation_data.dart';

const String _baseUrl = 'http://10.0.2.2:8080';

abstract class TaskApiClient {
  Future<Map<String, dynamic>?> createTask(TaskCreationData task);
  Future<bool> updateTask(int id, TaskCreationData task);  // <- now returns bool
  Future<List<Map<String, dynamic>>> getTasksByDevice(int deviceId);
  Future<bool> deleteTask(int id);                         // <- accept 204 as success
}

class HttpTaskApiClient implements TaskApiClient {
  final http.Client _client = http.Client();

  @override
  Future<Map<String, dynamic>?> createTask(TaskCreationData task) async {
    try {
      final requestBody = jsonEncode(task.toJson());
      debugPrint('📤 CREATE TASK REQUEST BODY: $requestBody');

      final response = await _client.post(
        Uri.parse('$_baseUrl/task'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      _logResponse('CREATE TASK', response);

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        debugPrint('✅ CREATE TASK RESPONSE BODY (RAW): $responseBody');
        if (responseBody is Map<String, dynamic>) {
          return responseBody;
        }
      }
      return null;
    } catch (e) {
      debugPrint('💥 CREATE TASK ERROR: $e');
      return null;
    }
  }

  @override
  Future<bool> updateTask(int id, TaskCreationData task) async {
    try {
      final requestBody = jsonEncode(task.toJson());
      debugPrint('📤 UPDATE TASK REQUEST BODY: $requestBody');

      final response = await _client.put(
        Uri.parse('$_baseUrl/task/$id'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      _logResponse('UPDATE TASK', response);

      // Backend now returns 204 No Content (or 200 if you ever choose)
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('💥 UPDATE TASK ERROR: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTasksByDevice(int deviceId) async {
    try {
      debugPrint('📤 GET TASKS FOR DEVICE: $deviceId');

      final response = await _client.get(
        Uri.parse('$_baseUrl/task/device/$deviceId'),
      );

      _logResponse('GET TASKS', response);

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        debugPrint('✅ GET TASKS RESPONSE BODY (RAW): $responseBody');
        if (responseBody is List) {
          return responseBody.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('💥 GET TASKS ERROR: $e');
      return [];
    }
  }

  @override
  Future<bool> deleteTask(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/task/$id'),
      );
      _logResponse('DELETE TASK', response);
      // Accept 204 and 200 as success
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('💥 DELETE TASK ERROR: $e');
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