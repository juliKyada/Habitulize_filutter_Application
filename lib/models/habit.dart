class Habit {
  final String id;
  String name;
  bool isCompleted;
  int streak;
  DateTime? lastCompletedDate;

  Habit({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.streak = 0,
    this.lastCompletedDate,
  });

  // Convert a Habit object into a Map object
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCompleted': isCompleted,
        'streak': streak,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      };

  // Create a Habit object from a Map object
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      isCompleted: json['isCompleted'] ?? false,
      streak: json['streak'] ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'])
          : null,
    );
  }
}
