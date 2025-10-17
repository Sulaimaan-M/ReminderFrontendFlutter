import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/device_token_api_client.dart';

class DeviceTokenService {
  final DeviceTokenApiClient _apiClient;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _PREF_FCM_TOKEN = 'fcm_token';
  static const String _PREF_DEVICE_ID = 'device_id';

  DeviceTokenService({DeviceTokenApiClient? apiClient})
      : _apiClient = apiClient ?? HttpDeviceTokenApiClient();

  Future<void> initialize() async {
    debugPrint('🚀 [DeviceTokenService] Initializing FCM...');

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _messaging.getToken();
      await _handleToken(token);

      _messaging.onTokenRefresh.listen((newToken) async {
        await _handleToken(newToken);
      });
    }
  }

  /// Returns the saved deviceId (or null if not registered)
  Future<int?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_PREF_DEVICE_ID);
  }

  Future<void> _handleToken(String? token) async {
    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_PREF_FCM_TOKEN);

    if (storedToken != token) {
      debugPrint('🆕 Registering new FCM token: $token');

      final response = await _apiClient.registerToken(token);

      if (response.success && response.deviceId != null) {
        await prefs.setString(_PREF_FCM_TOKEN, token);
        await prefs.setInt(_PREF_DEVICE_ID, response.deviceId!);
        debugPrint('✅ Registered device. ID: ${response.deviceId}');
      } else {
        debugPrint('❌ Registration failed: ${response.errorMessage}');
      }
    }
  }
}