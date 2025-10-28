class MinimalReminder {
  final int id;
  final DateTime remindedAt;
  final bool isCompleted;

  MinimalReminder({
    required this.id,
    required this.remindedAt,
    required this.isCompleted,
  });

  // Factory constructor to create from JSON
  factory MinimalReminder.fromJson(Map<String, dynamic> json) {
    return MinimalReminder(
      id: json['id'] as int,
      remindedAt: DateTime.parse(json['remindedAt'] as String),
      isCompleted: json['isCompleted'] as bool,
    );
  }

  // Convert to JSON (if needed for sending data back)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remindedAt': remindedAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}