import 'package:flutter/material.dart';
import '../data/predefined_habits.dart';
import '../services/habit_service.dart';

class AddHabitScreen extends StatefulWidget {
  final VoidCallback onHabitAdded;

  const AddHabitScreen({super.key, required this.onHabitAdded}); // Using super.key

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final HabitService _habitService = HabitService();
  final TextEditingController _customHabitController = TextEditingController();

  Future<void> _addHabit(String name) async {
    await _habitService.addHabit(name);
    widget.onHabitAdded();
    if (mounted) { // Added mounted check
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _customHabitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose from predefined habits:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: predefinedHabits.length,
                itemBuilder: (context, index) {
                  final habitName = predefinedHabits[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      title: Text(
                        habitName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.secondary), // Using theme color
                        onPressed: () => _addHabit(habitName),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Or add your own habit:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customHabitController,
              decoration: InputDecoration(
                hintText: 'e.g., Learn Spanish for 15 minutes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    if (_customHabitController.text.isNotEmpty) {
                      _addHabit(_customHabitController.text);
                    }
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addHabit(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
