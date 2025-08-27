import 'package:flutter/material.dart';
import '../services/habit_service.dart';

class SuggestionsScreen extends StatefulWidget {
  final VoidCallback onHabitAdded;

  const SuggestionsScreen({super.key, required this.onHabitAdded}); // Using super.key

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final HabitService _habitService = HabitService();
  int _currentQuestionIndex = 0;
  String _selectedAnswer = '';
  List<String> _suggestedHabits = [];

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How would you describe your current lifestyle?',
      'answers': ['Sedentary', 'Moderately active', 'Very active'],
      'suggestions': {
        'Sedentary': ['Walk for 30 minutes', 'Stretch for 10 minutes'],
        'Moderately active': ['Jog for 20 minutes', 'Try a new sport'],
        'Very active': ['Practice yoga', 'Do strength training'],
      }
    },
    {
      'question': 'What is your primary goal for forming a new habit?',
      'answers': ['Improve physical health', 'Improve mental health', 'Learn something new'],
      'suggestions': {
        'Improve physical health': ['Drink 8 glasses of water', 'Eat one fruit daily'],
        'Improve mental health': ['Meditate for 10 minutes', 'Write in a journal'],
        'Learn something new': ['Read a book for 20 minutes', 'Practice a musical instrument'],
      }
    },
  ];

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = '';
      });
    } else {
      // If all questions are answered, show the suggestions
      _generateSuggestions();
    }
  }

  void _generateSuggestions() {
    List<String> suggestions = [];
    // Changed forEach to a for-in loop to avoid linter warning
    for (var q in _questions) {
      if (_selectedAnswer.isNotEmpty && q['answers'].contains(_selectedAnswer)) {
        suggestions.addAll(q['suggestions'][_selectedAnswer] ?? []);
      }
    }

    setState(() {
      _suggestedHabits = suggestions;
    });
  }

  Future<void> _addSuggestedHabit(String habitName) async {
    await _habitService.addHabit(habitName);
    widget.onHabitAdded();
    if (mounted) { // Added mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$habitName added to your habits!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Suggestions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _suggestedHabits.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _questions[_currentQuestionIndex]['question'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (var answer in (_questions[_currentQuestionIndex]['answers'] as List<String>))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedAnswer = answer;
                          });
                          _nextQuestion();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Theme.of(context).colorScheme.primary, // Themed button
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          elevation: 4,
                        ),
                        child: Text(answer),
                      ),
                    ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Here are some habits suggested for you:',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _suggestedHabits.length,
                      itemBuilder: (context, index) {
                        final habitName = _suggestedHabits[index];
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
                                  color: Theme.of(context).colorScheme.secondary),
                              onPressed: () => _addSuggestedHabit(habitName),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}