import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMTokenManager {
  static const String _tokenKey = 'fcm_token';
  static const String _deviceIdKey = 'device_id';

  // Get current token (fetch if missing)
  static Future<String?> getOrCreateToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    // If no token or it's outdated, fetch new one
    if (token == null) {
      token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await prefs.setString(_tokenKey, token);
      }
    }

    return token;
  }

  // Update token if refreshed
  static Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    // TODO: Send to backend
  }

  // Optional: Store backend's device ID
  static Future<void> setDeviceId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, id);
  }

  static Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }
}