// api/device_token_api_client.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/device_registration_response.dart';

const String _deviceTokenUrl = 'http://10.0.2.2:8080/register';

abstract class DeviceTokenApiClient {
  Future<DeviceRegistrationResponse> registerToken(String fcmToken);
}

class HttpDeviceTokenApiClient implements DeviceTokenApiClient {
  @override
  Future<DeviceRegistrationResponse> registerToken(String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse(_deviceTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fcmToken': fcmToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final int? id = jsonBody['id'] as int?;

        if (id != null) {
          return DeviceRegistrationResponse.success(id);
        } else {
          return DeviceRegistrationResponse.failure('ID missing in response');
        }
      } else {
        return DeviceRegistrationResponse.failure(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } on TimeoutException {
      return DeviceRegistrationResponse.failure('Request timed out');
    } catch (e) {
      return DeviceRegistrationResponse.failure('Network error: $e');
    }
  }
}