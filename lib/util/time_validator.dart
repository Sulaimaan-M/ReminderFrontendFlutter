// lib/utils/time_validator.dart

String? validateTime(String? input) {
  if (input == null || input.trim().isEmpty) return 'Required';
  final parts = input.split(':');
  if (parts.length != 2) return 'Use format HH:MM';

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return 'Invalid time (00:00–23:59)';
  }
  return null;
}