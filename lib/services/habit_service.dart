import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/badge.dart';
import '../models/user_stats.dart';

// Service to handle all habit-related data operations
class HabitService {
  static const _habitsKey = 'habits';
  static const _userStatsKey = 'user_stats';
  static const Uuid _uuid = Uuid();

  // Get all habits from SharedPreferences
  Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getStringList(_habitsKey) ?? [];
    return habitsJson.map((jsonString) {
      return Habit.fromJson(jsonDecode(jsonString));
    }).toList();
  }

  // Add a new habit to SharedPreferences
  Future<void> addHabit(String name, {String category = 'General', String iconEmoji = '✅', int priority = 3}) async {
    final prefs = await SharedPreferences.getInstance();
    final habit = Habit(
      id: _uuid.v4(), 
      name: name,
      category: category,
      iconEmoji: iconEmoji,
      priority: priority,
    );
    List<String> habitsJson = prefs.getStringList(_habitsKey) ?? [];
    habitsJson.add(jsonEncode(habit.toJson()));
    await prefs.setStringList(_habitsKey, habitsJson);
    
    // Check for habit collector badge
    await _checkAndAwardBadges();
  }

  // Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    final prefs = await SharedPreferences.getInstance();
    List<Habit> habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      habits[index] = updatedHabit;
      final habitsJson = habits.map((h) => jsonEncode(h.toJson())).toList();
      await prefs.setStringList(_habitsKey, habitsJson);
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<Habit> habits = await getHabits();
    habits.removeWhere((h) => h.id == id);
    final habitsJson = habits.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_habitsKey, habitsJson);
  }

  // Complete a habit with gamification
  Future<List<Badge>> completeHabit(String habitId) async {
    final habits = await getHabits();
    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    
    if (habitIndex == -1) return [];
    
    final habit = habits[habitIndex];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if already completed today
    if (habit.isCompletedToday) return [];
    
    // Update habit completion
    final yesterday = today.subtract(const Duration(days: 1));
    final wasCompletedYesterday = habit.lastCompletedDate != null && 
        DateTime(habit.lastCompletedDate!.year, habit.lastCompletedDate!.month, habit.lastCompletedDate!.day) == yesterday;
    
    if (wasCompletedYesterday) {
      habit.streak++;
    } else {
      habit.streak = 1;
    }
    
    // Update best streak
    if (habit.streak > habit.bestStreak) {
      habit.bestStreak = habit.streak;
    }
    
    habit.lastCompletedDate = now;
    habit.totalCompletions++;
    habit.completionHistory = [...habit.completionHistory, now];
    
    await updateHabit(habit);
    await _updateUserStats();
    
    return await _checkAndAwardBadges();
  }

  // User Stats methods
  Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_userStatsKey);
    if (statsJson == null) {
      return UserStats();
    }
    return UserStats.fromJson(jsonDecode(statsJson));
  }

  Future<void> _updateUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final habits = await getHabits();
    final currentStats = await getUserStats();
    
    final totalCompletions = habits.fold<int>(0, (sum, habit) => sum + habit.totalCompletions);
    final longestStreak = habits.fold<int>(0, (max, habit) => habit.bestStreak > max ? habit.bestStreak : max);
    final totalDaysActive = habits.fold<int>(0, (sum, habit) => sum + habit.daysActive);
    
    // Calculate level and experience
    final newExperience = totalCompletions * 10 + longestStreak * 5;
    final newLevel = (newExperience / 100).floor() + 1;
    
    final updatedStats = currentStats.copyWith(
      totalHabitsCompleted: totalCompletions,
      currentLongestStreak: longestStreak,
      totalDaysActive: totalDaysActive,
      experience: newExperience,
      level: newLevel,
      lastActiveDate: DateTime.now(),
    );
    
    await prefs.setString(_userStatsKey, jsonEncode(updatedStats.toJson()));
  }

  Future<List<Badge>> _checkAndAwardBadges() async {
    final habits = await getHabits();
    final stats = await getUserStats();
    final newBadges = <Badge>[];
    
    // Check various badge conditions
    final earnedBadgeTypes = stats.earnedBadges.map((b) => b.type).toSet();
    
    // First Step Badge
    if (!earnedBadgeTypes.contains(BadgeType.firstStep) && 
        habits.any((h) => h.totalCompletions > 0)) {
      newBadges.add(_createBadge(BadgeType.firstStep));
    }
    
    // Week Warrior Badge
    if (!earnedBadgeTypes.contains(BadgeType.weekWarrior) && 
        habits.any((h) => h.bestStreak >= 7)) {
      newBadges.add(_createBadge(BadgeType.weekWarrior));
    }
    
    // Month Master Badge
    if (!earnedBadgeTypes.contains(BadgeType.monthMaster) && 
        habits.any((h) => h.bestStreak >= 30)) {
      newBadges.add(_createBadge(BadgeType.monthMaster));
    }
    
    // Streak Legend Badge
    if (!earnedBadgeTypes.contains(BadgeType.streakLegend) && 
        habits.any((h) => h.bestStreak >= 100)) {
      newBadges.add(_createBadge(BadgeType.streakLegend));
    }
    
    // Habit Collector Badge
    if (!earnedBadgeTypes.contains(BadgeType.habitCollector) && 
        habits.length >= 10) {
      newBadges.add(_createBadge(BadgeType.habitCollector));
    }
    
    // Consistency Badge
    if (!earnedBadgeTypes.contains(BadgeType.consistency) && 
        stats.totalHabitsCompleted >= 50) {
      newBadges.add(_createBadge(BadgeType.consistency));
    }
    
    if (newBadges.isNotEmpty) {
      await _saveBadges(newBadges);
    }
    
    return newBadges;
  }
  
  Badge _createBadge(BadgeType type) {
    final template = Badge.getBadgeTemplate(type);
    return Badge(
      id: _uuid.v4(),
      type: template.type,
      name: template.name,
      description: template.description,
      iconEmoji: template.iconEmoji,
      earnedDate: DateTime.now(),
      value: template.value,
    );
  }
  
  Future<void> _saveBadges(List<Badge> newBadges) async {
    final stats = await getUserStats();
    final updatedBadges = [...stats.earnedBadges, ...newBadges];
    final updatedStats = stats.copyWith(earnedBadges: updatedBadges);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatsKey, jsonEncode(updatedStats.toJson()));
  }

  // Motivational quotes
  List<String> getDailyQuotes() {
    return [
      "Small steps daily lead to big changes yearly! 🌟",
      "Consistency is the key to success! 💪",
      "Every habit completed is a victory! 🏆",
      "You're building a better version of yourself! ✨",
      "Progress, not perfection! 🎯",
      "One day at a time, one habit at a time! 🌱",
      "Your future self will thank you! 🙏",
      "Discipline is choosing between what you want now and what you want most! 💎",
      "Great things never come from comfort zones! 🚀",
      "The only impossible journey is the one you never begin! 🛤️"
    ];
  }

  String getTodaysQuote() {
    final quotes = getDailyQuotes();
    final today = DateTime.now().day;
    return quotes[today % quotes.length];
  }
}

// lib/screens/home_screen.dart
