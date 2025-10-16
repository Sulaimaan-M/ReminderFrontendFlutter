// lib/service/fcm_notification_service.dart

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMNotificationService {
  static final FCMNotificationService _instance = FCMNotificationService._internal();
  factory FCMNotificationService() => _instance;
  FCMNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      return;
    }

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('⚠️ Notification permission request failed: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    try {
      await _localNotifications.initialize(initializationSettings,
          onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
    } catch (e) {
      debugPrint('❌ Local notifications initialization failed: $e');
      return;
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 Foreground message received: ${message.messageId}');
    _showLocalNotification(message);
  }

  void _onDidReceiveNotificationResponse(NotificationResponse details) {
    debugPrint('📌 Notification tapped: ${details.id}, payload: ${details.payload}');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification?.title == null && notification?.body == null) {
      debugPrint('⚠️ Skipping notification: no title or body');
      return;
    }

    // ✅ SAFE 32-BIT ID: Use microseconds mod max int32
    final int id = DateTime.now().microsecondsSinceEpoch % 2147483647;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Notifications for your reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // ✅ Ensure channel is recreated if deleted
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await _localNotifications.show(
        id,
        notification?.title ?? 'Reminder',
        notification?.body ?? 'You have a new reminder',
        platformChannelSpecifics,
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );
      debugPrint('✅ Local notification shown with ID: $id');
    } catch (e) {
      debugPrint('❌ Failed to show local notification: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('❌ Background: Firebase init failed: $e');
      return;
    }

    final localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    try {
      await localNotifications.initialize(initializationSettings);
    } catch (e) {
      debugPrint('❌ Background: Local notifications init failed: $e');
      return;
    }

    final notification = message.notification;
    if (notification?.title == null && notification?.body == null) {
      debugPrint('⚠️ Background: Skipping notification (no content)');
      return;
    }

    // ✅ SAFE 32-BIT ID IN BACKGROUND
    final int id = DateTime.now().microsecondsSinceEpoch % 2147483647;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Notifications for your reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await localNotifications.show(
        id,
        notification?.title ?? 'Reminder',
        notification?.body ?? 'You have a new reminder',
        platformChannelSpecifics,
      );
      debugPrint('✅ Background notification shown with ID: $id');
    } catch (e) {
      debugPrint('❌ Background: Failed to show notification: $e');
    }
  }
}