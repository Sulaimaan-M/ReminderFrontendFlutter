// lib/model/yearly_selection.dart

class YearlySelection {
  final int month;
  final int day;

  YearlySelection(this.month, this.day);

  @override
  bool operator ==(Object other) =>
      other is YearlySelection && month == other.month && day == other.day;

  @override
  int get hashCode => Object.hash(month, day);
}