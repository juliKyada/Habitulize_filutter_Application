class Habit {
  final String id;
  String name;
  bool isCompleted;
  int streak;
  int bestStreak;
  DateTime? lastCompletedDate;
  DateTime createdDate;
  List<DateTime> completionHistory;
  String category;
  String iconEmoji;
  int priority; // 1-5 scale
  int totalCompletions;

  Habit({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.streak = 0,
    this.bestStreak = 0,
    this.lastCompletedDate,
    DateTime? createdDate,
    this.completionHistory = const [],
    this.category = 'General',
    this.iconEmoji = '✅',
    this.priority = 3,
    this.totalCompletions = 0,
  }) : createdDate = createdDate ?? DateTime.now();

  // Convert a Habit object into a Map object
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCompleted': isCompleted,
        'streak': streak,
        'bestStreak': bestStreak,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'createdDate': createdDate.toIso8601String(),
        'completionHistory': completionHistory.map((date) => date.toIso8601String()).toList(),
        'category': category,
        'iconEmoji': iconEmoji,
        'priority': priority,
        'totalCompletions': totalCompletions,
      };

  // Create a Habit object from a Map object
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      isCompleted: json['isCompleted'] ?? false,
      streak: json['streak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'])
          : null,
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
      completionHistory: (json['completionHistory'] as List<dynamic>?)
              ?.map((dateStr) => DateTime.parse(dateStr))
              .toList() ??
          [],
      category: json['category'] ?? 'General',
      iconEmoji: json['iconEmoji'] ?? '✅',
      priority: json['priority'] ?? 3,
      totalCompletions: json['totalCompletions'] ?? 0,
    );
  }

  // Helper methods for gamification
  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );
    return lastCompleted == today;
  }

  int get daysActive {
    return completionHistory.length;
  }

  double get completionRate {
    final daysSinceCreation = DateTime.now().difference(createdDate).inDays + 1;
    return daysSinceCreation > 0 ? (daysActive / daysSinceCreation) : 0.0;
  }
}
