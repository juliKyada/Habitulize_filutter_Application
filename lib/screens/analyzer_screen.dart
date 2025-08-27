import 'package:flutter/material.dart';
import '../models/habit.dart';

class AnalyzerScreen extends StatelessWidget {
  final List<Habit> habits;

  const AnalyzerScreen({super.key, required this.habits}); // Using super.key

  String _getAnalysis() {
    if (habits.isEmpty) {
      return 'Start tracking habits to see your progress here!';
    }
    final totalHabits = habits.length;
    final totalStreaks = habits.fold(0, (sum, habit) => sum + habit.streak);
    final longestStreak =
        habits.isNotEmpty ? habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b) : 0;
    
    int completedHabitsToday = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (var habit in habits) {
      if (habit.lastCompletedDate != null && 
          DateTime(habit.lastCompletedDate!.year, habit.lastCompletedDate!.month, habit.lastCompletedDate!.day) == today) {
        completedHabitsToday++;
      }
    }
    
    return '''
Habit Analysis:

Total Habits Tracked: $totalHabits
Habits Completed Today: $completedHabitsToday
Longest Streak: $longestStreak day(s)
Total Streaks Built: $totalStreaks day(s)
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Analyzer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8, // Increased elevation
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // More rounded
          color: Theme.of(context).colorScheme.surfaceContainerHighest, // Themed background
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _getAnalysis(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
