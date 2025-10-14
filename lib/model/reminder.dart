// model/reminder.dart

enum IntervalType {
  simple,
  daily,
  weekly,
  monthly,
  yearly;

  // Human-readable label for UI
  String get label {
    switch (this) {
      case simple: return 'Simple';
      case daily: return 'Daily';
      case weekly: return 'Weekly';
      case monthly: return 'Monthly';
      case yearly: return 'Yearly';
    }
  }

  // Convert from String (e.g., from API)
  static IntervalType fromString(String? value) {
    if (value == null) return IntervalType.simple;
    final lower = value.toLowerCase();
    for (var type in IntervalType.values) {
      if (type.name == lower) return type;
    }
    return IntervalType.simple;
  }

  // For API (e.g., "SIMPLE", "DAILY")
  String toApiValue() => name.toUpperCase();
}

class Reminder {
  final String reminderTxt;
  final DateTime remindAt;
  final IntervalType interval;

  Reminder({
    required this.reminderTxt,
    required this.remindAt,
    required this.interval,
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
      reminderTxt: json['reminderTxt'] ?? 'Untitled',
      remindAt: parsedDateTime,
      interval: IntervalType.fromString(json['interval'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderTxt': reminderTxt,
      'remindAt': remindAt.toIso8601String(),
      'interval': interval.toApiValue(),
    };
  }
}