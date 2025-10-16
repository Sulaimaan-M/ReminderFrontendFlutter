// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reminder_app/screen/list_reminder_screen.dart';
import 'package:reminder_app/service/device_token_service.dart';
import 'package:reminder_app/service/fcm_notification_service.dart'; // 👈 NEW

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize FCM + Local Notifications
  await FCMNotificationService().initialize();

  // Register FCM token with your backend
  final deviceTokenService = DeviceTokenService();
  await deviceTokenService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ReminderListScreen(),
    );
  }
}