// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reminder_app/service/device_token_service.dart';
import 'screen/list_reminder_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔹 Delegate ALL FCM/token logic to the service
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