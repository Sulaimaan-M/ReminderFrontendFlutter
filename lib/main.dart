import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reminder_app/screen/home_screen.dart';
import 'package:reminder_app/service/device_token_service.dart';
import 'package:reminder_app/service/fcm_notification_service.dart';
import 'package:reminder_app/util/route_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FCMNotificationService().initialize();

  final deviceTokenService = DeviceTokenService();
  await deviceTokenService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      home: const HomeScreen(),
    );
  }
}