import 'badge.dart';

class UserStats {
  final int totalHabitsCompleted;
  final int currentLongestStreak;
  final int totalDaysActive;
  final List<HabitBadge> earnedBadges;
  final int level;
  final int experience;
  final DateTime? lastActiveDate;
  final Map<String, int> weeklyProgress; // Day of week -> completed habits count

  UserStats({
    this.totalHabitsCompleted = 0,
    this.currentLongestStreak = 0,
    this.totalDaysActive = 0,
    this.earnedBadges = const [],
    this.level = 1,
    this.experience = 0,
    this.lastActiveDate,
    this.weeklyProgress = const {},
  });

  int get experienceForNextLevel => level * 100;
  
  double get progressToNextLevel => experience / experienceForNextLevel;

  String get levelTitle {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Novice';
    if (level < 20) return 'Expert';
    if (level < 50) return 'Master';
    return 'Legend';
  }

  Map<String, dynamic> toJson() => {
        'totalHabitsCompleted': totalHabitsCompleted,
        'currentLongestStreak': currentLongestStreak,
        'totalDaysActive': totalDaysActive,
        'earnedBadges': earnedBadges.map((badge) => badge.toJson()).toList(),
        'level': level,
        'experience': experience,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'weeklyProgress': weeklyProgress,
      };

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalHabitsCompleted: json['totalHabitsCompleted'] ?? 0,
      currentLongestStreak: json['currentLongestStreak'] ?? 0,
      totalDaysActive: json['totalDaysActive'] ?? 0,
      earnedBadges: (json['earnedBadges'] as List<dynamic>?)
              ?.map((badgeJson) => HabitBadge.fromJson(badgeJson))
              .toList() ??
          [],
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'])
          : null,
      weeklyProgress: Map<String, int>.from(json['weeklyProgress'] ?? {}),
    );
  }

  UserStats copyWith({
    int? totalHabitsCompleted,
    int? currentLongestStreak,
    int? totalDaysActive,
    List<HabitBadge>? earnedBadges,
    int? level,
    int? experience,
    DateTime? lastActiveDate,
    Map<String, int>? weeklyProgress,
  }) {
    return UserStats(
      totalHabitsCompleted: totalHabitsCompleted ?? this.totalHabitsCompleted,
      currentLongestStreak: currentLongestStreak ?? this.currentLongestStreak,
      totalDaysActive: totalDaysActive ?? this.totalDaysActive,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
    );
  }
}