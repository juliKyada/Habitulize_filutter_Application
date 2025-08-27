import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import 'add_habit_screen.dart';
import 'analyzer_screen.dart';
import 'suggestions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });
    final habits = await _habitService.getHabits();
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Future<void> _toggleHabitCompletion(Habit habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final bool wasCompletedToday = habit.lastCompletedDate != null && 
        DateTime(habit.lastCompletedDate!.year, habit.lastCompletedDate!.month, habit.lastCompletedDate!.day) == today;

    if (!wasCompletedToday) {
      final yesterday = today.subtract(const Duration(days: 1));
      final bool wasCompletedYesterday = habit.lastCompletedDate != null && 
          DateTime(habit.lastCompletedDate!.year, habit.lastCompletedDate!.month, habit.lastCompletedDate!.day) == yesterday;
      
      if (wasCompletedYesterday) {
        habit.streak++;
      } else {
        habit.streak = 1;
      }
      habit.lastCompletedDate = now;
      await _habitService.updateHabit(habit);
      _loadHabits();
    }
  }

  Future<void> _deleteHabit(String id) async {
    await _habitService.deleteHabit(id);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SuggestionsScreen(
                    onHabitAdded: () => _loadHabits(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AnalyzerScreen(habits: _habits),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _habits.isEmpty
                  ? const Center(
                      child: Text('No habits yet. Start by adding one!'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        return HabitCard(
                          habit: habit,
                          onToggle: () => _toggleHabitCompletion(habit),
                          onDelete: () => _deleteHabit(habit.id),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddHabitScreen(
                onHabitAdded: () => _loadHabits(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  bool _isCompletedToday(Habit habit) {
    if (habit.lastCompletedDate == null) {
      return false;
    }
    final now = DateTime.now();
    return habit.lastCompletedDate!.day == now.day &&
        habit.lastCompletedDate!.month == now.month &&
        habit.lastCompletedDate!.year == now.year;
  }

  @override
  Widget build(BuildContext context) {
    final bool isToday = _isCompletedToday(habit);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isToday ? Icons.check_circle : Icons.check_circle_outline,
            color: isToday ? Colors.green : Colors.grey,
          ),
          onPressed: onToggle,
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: isToday ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          'Streak: ${habit.streak} day${habit.streak == 1 ? '' : 's'}',
          style: TextStyle(
            color: habit.streak > 0 ? Colors.blueAccent : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}