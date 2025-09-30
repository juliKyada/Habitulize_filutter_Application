enum BadgeType {
  firstStep,
  weekWarrior,
  monthMaster,
  streakLegend,
  habitCollector,
  perfectWeek,
  consistency,
  earlyBird,
  nightOwl,
  weekend,
}

class HabitBadge {
  final String id;
  final BadgeType type;
  final String name;
  final String description;
  final String iconEmoji;
  final DateTime earnedDate;
  final int value; // For sorting/ranking badges

  HabitBadge({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.earnedDate,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'name': name,
        'description': description,
        'iconEmoji': iconEmoji,
        'earnedDate': earnedDate.toIso8601String(),
        'value': value,
      };

  factory HabitBadge.fromJson(Map<String, dynamic> json) {
    return HabitBadge(
      id: json['id'],
      type: BadgeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => BadgeType.firstStep,
      ),
      name: json['name'],
      description: json['description'],
      iconEmoji: json['iconEmoji'],
      earnedDate: DateTime.parse(json['earnedDate']),
      value: json['value'],
    );
  }

  static HabitBadge getBadgeTemplate(BadgeType type) {
    switch (type) {
      case BadgeType.firstStep:
        return HabitBadge(
          id: '',
          type: type,
          name: 'First Step',
          description: 'Complete your first habit!',
          iconEmoji: '🌱',
          earnedDate: DateTime.now(),
          value: 1,
        );
      case BadgeType.weekWarrior:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Week Warrior',
          description: 'Maintain a 7-day streak!',
          iconEmoji: '⚔️',
          earnedDate: DateTime.now(),
          value: 2,
        );
      case BadgeType.monthMaster:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Month Master',
          description: 'Achieve a 30-day streak!',
          iconEmoji: '👑',
          earnedDate: DateTime.now(),
          value: 3,
        );
      case BadgeType.streakLegend:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Streak Legend',
          description: 'Reach 100-day streak!',
          iconEmoji: '🏆',
          earnedDate: DateTime.now(),
          value: 5,
        );
      case BadgeType.habitCollector:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Habit Collector',
          description: 'Create 10 different habits!',
          iconEmoji: '📚',
          earnedDate: DateTime.now(),
          value: 2,
        );
      case BadgeType.perfectWeek:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Perfect Week',
          description: 'Complete all habits for 7 days!',
          iconEmoji: '✨',
          earnedDate: DateTime.now(),
          value: 3,
        );
      case BadgeType.consistency:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Consistency King',
          description: 'Complete habits for 50 days total!',
          iconEmoji: '🎯',
          earnedDate: DateTime.now(),
          value: 4,
        );
      case BadgeType.earlyBird:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Early Bird',
          description: 'Complete habits before 8 AM!',
          iconEmoji: '🐦',
          earnedDate: DateTime.now(),
          value: 2,
        );
      case BadgeType.nightOwl:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Night Owl',
          description: 'Complete habits after 8 PM!',
          iconEmoji: '🦉',
          earnedDate: DateTime.now(),
          value: 2,
        );
      case BadgeType.weekend:
        return HabitBadge(
          id: '',
          type: type,
          name: 'Weekend Warrior',
          description: 'Stay consistent on weekends!',
          iconEmoji: '🏖️',
          earnedDate: DateTime.now(),
          value: 2,
        );
    }
  }
}