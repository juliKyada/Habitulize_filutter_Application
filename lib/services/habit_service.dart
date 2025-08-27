import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

// Service to handle all habit-related data operations
class HabitService {
  static const _habitsKey = 'habits';
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
  Future<void> addHabit(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final habit = Habit(id: _uuid.v4(), name: name);
    List<String> habitsJson = prefs.getStringList(_habitsKey) ?? [];
    habitsJson.add(jsonEncode(habit.toJson()));
    await prefs.setStringList(_habitsKey, habitsJson);
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
}

// lib/screens/home_screen.dart
