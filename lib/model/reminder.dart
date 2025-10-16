// lib/model/reminder.dart

import '../util/timezone_helper.dart';

enum IntervalType {
  simple,
  daily,
  weekly,
  monthly,
  yearly;

  String get label {
    switch (this) {
      case simple: return 'Simple';
      case daily: return 'Daily';
      case weekly: return 'Weekly';
      case monthly: return 'Monthly';
      case yearly: return 'Yearly';
    }
  }

  static IntervalType fromString(String? value) {
    if (value == null) return IntervalType.simple;
    final upper = value.toUpperCase();
    for (var type in IntervalType.values) {
      if (type.toApiValue() == upper) return type;
    }
    return IntervalType.simple;
  }

  String toApiValue() => name.toUpperCase();
}

class Reminder {
  final int? id;
  final String reminderTxt;
  final DateTime remindAt;
  final IntervalType interval;
  final int deviceId;

  Reminder({
    this.id,
    required this.reminderTxt,
    required this.remindAt,
    required this.interval,
    required this.deviceId,
  });

  /// Creates a Reminder from backend JSON (UTC time) and converts to local time
  factory Reminder.fromBackendJson(Map<String, dynamic> json) {
    // 🔑 FIX: Use correct field names from backend
    final text = json['text'] as String?; // 👈 'text' not 'reminderTxt'
    final intervalTypeStr = json['intervalType'] as String?; // 👈 'intervalType' not 'interval'
    final remindAtStr = json['remindAt'] as String?;
    final deviceToken = json['deviceToken'] as Map<String, dynamic>?;
    final deviceId = deviceToken?['id'] as int?;

    DateTime parsedDateTime;
    if (remindAtStr != null) {
      try {
        parsedDateTime = DateTime.parse(remindAtStr).toLocal();
      } catch (e) {
        parsedDateTime = DateTime.now();
      }
    } else {
      parsedDateTime = DateTime.now();
    }

    final interval = IntervalType.fromString(intervalTypeStr);

    return Reminder(
      id: json['id'] as int?,
      reminderTxt: text ?? 'Untitled',
      remindAt: parsedDateTime,
      interval: interval,
      deviceId: deviceId ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderTxt': reminderTxt,
      'remindAt': toZonedDateTimeString(remindAt),
      'interval': interval.toApiValue(),
      'deviceTokenId': deviceId,
    };
  }
}