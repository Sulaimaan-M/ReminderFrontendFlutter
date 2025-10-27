import 'package:flutter/material.dart';

// Moved from reminder.dart
enum IntervalType {
  simple('Simple', Icons.event),
  daily('Daily', Icons.today),
  weekly('Weekly', Icons.view_week),
  monthly('Monthly', Icons.calendar_month),
  yearly('Yearly', Icons.calendar_today);

  const IntervalType(this.label, this.icon);
  final String label;
  final IconData icon;
}