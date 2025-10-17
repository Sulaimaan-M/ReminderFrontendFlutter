String toZonedDateTimeString(DateTime localDateTime) {
  final local = localDateTime.isUtc ? localDateTime.toLocal() : localDateTime;
  final offset = local.timeZoneOffset;
  final hours = offset.inHours;
  final minutes = offset.inMinutes.abs() % 60;
  final sign = hours >= 0 ? '+' : '-';
  final paddedHours = hours.abs().toString().padLeft(2, '0');
  final paddedMinutes = minutes.toString().padLeft(2, '0');
  final offsetString = '$sign$paddedHours:$paddedMinutes';

  final dateString = '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}T'
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}:'
      '${local.second.toString().padLeft(2, '0')}';

  return '$dateString$offsetString';
}