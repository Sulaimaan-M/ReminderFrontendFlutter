// lib/model/reminder.dart

import '../util/timezone_helper.dart'; // 👈 NEW IMPORT

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
    final lower = value.toLowerCase();
    for (var type in IntervalType.values) {
      if (type.name == lower) return type;
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

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final remindAtStr = json['remindAt'] as String?;
    DateTime parsedDateTime;
    if (remindAtStr != null) {
      try {
        parsedDateTime = DateTime.parse(remindAtStr);
      } catch (e) {
        parsedDateTime = DateTime.now();
      }
    } else {
      parsedDateTime = DateTime.now();
    }

    return Reminder(
      id: json['id'] as int?,
      reminderTxt: json['reminderTxt'] ?? 'Untitled',
      remindAt: parsedDateTime,
      interval: IntervalType.fromString(json['interval'] as String?),
      deviceId: json['deviceTokenId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderTxt': reminderTxt,
      'remindAt': toZonedDateTimeString(remindAt), // 👈 FIXED
      'interval': interval.toApiValue(),
      'deviceTokenId': deviceId,
    };
  }
}