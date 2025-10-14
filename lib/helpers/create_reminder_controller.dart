// controller/create_reminder_controller.dart

import 'package:flutter/material.dart';
import '../model/reminder.dart';
import '../model/repetition.dart';
import '../service/reminder_service.dart';
import '../widget/create_reminder/yearly_section.dart';

class CreateReminderController {
  final Reminder? initialReminder;

  // Form controllers
  final textController = TextEditingController();
  int hour = DateTime.now().hour;
  int minute = DateTime.now().minute;

  // Repetition state
  Repetition repetition = Repetition.simple;
  DateTime simpleDate = DateTime.now();
  int selectedWeekday = DateTime.now().weekday - 1;
  int monthlyDay = DateTime.now().day;
  YearlySelection yearlySelection = YearlySelection(DateTime.now().month, DateTime.now().day);

  CreateReminderController({this.initialReminder}) {
    _initialize();
  }

  void _initialize() {
    if (initialReminder != null) {
      final r = initialReminder!;
      textController.text = r.reminderTxt;
      hour = r.remindAt.hour;
      minute = r.remindAt.minute;
      repetition = _mapIntervalToRepetition(r.interval);
      if (repetition == Repetition.simple) simpleDate = r.remindAt;
    }
  }

  Repetition _mapIntervalToRepetition(IntervalType type) {
    switch (type) {
      case IntervalType.simple: return Repetition.simple;
      case IntervalType.daily: return Repetition.daily;
      case IntervalType.weekly: return Repetition.weekly;
      case IntervalType.monthly: return Repetition.monthly;
      case IntervalType.yearly: return Repetition.yearly;
    }
  }

  Future<bool> saveReminder(BuildContext context) async {
    final formState = Form.of(context);
    if (formState == null || !formState.validate()) return false;

    DateTime remindAt;
    if (repetition == Repetition.simple) {
      remindAt = DateTime(simpleDate.year, simpleDate.month, simpleDate.day, hour, minute);
    } else {
      final now = DateTime.now();
      remindAt = DateTime(now.year, now.month, now.day, hour, minute);
    }

    final reminder = Reminder(
      reminderTxt: textController.text.trim(),
      remindAt: remindAt,
      interval: IntervalType.fromString(repetition.toIntervalType()),
    );

    return await ReminderService().createReminder(reminder);
  }
}

enum Repetition {
  simple, daily, weekly, monthly, yearly;

  String get label {
    switch (this) {
      case simple: return 'Simple';
      case daily: return 'Daily';
      case weekly: return 'Weekly';
      case monthly: return 'Monthly';
      case yearly: return 'Yearly';
    }
  }

  String toIntervalType() => name.toUpperCase();
}