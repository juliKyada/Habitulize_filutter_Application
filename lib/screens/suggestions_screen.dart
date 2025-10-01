import 'package:flutter/material.dart';
import '../services/habit_service.dart';
import '../services/ai_habit_service.dart';
import 'debug_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  final VoidCallback onHabitAdded;

  const SuggestionsScreen({super.key, required this.onHabitAdded}); // Using super.key

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final HabitService _habitService = HabitService();
  final PageController _pageController = PageController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // User profile data
  String _lifestyle = '';
  String _goal = '';
  int _availableTime = 30;
  List<String> _existingHabits = [];
  List<Map<String, dynamic>> _aiSuggestions = [];
  
  // Chat functionality
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    _loadExistingHabits();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingHabits() async {
    final habits = await _habitService.getHabits();
    setState(() {
      _existingHabits = habits.map((h) => h.name).toList();
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _getAISuggestions();
    }
  }

  Future<void> _getAISuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await AIHabitService.getPersonalizedSuggestions(
        existingHabits: _existingHabits,
        userGoal: _goal,
        lifestyle: _lifestyle,
        availableTime: _availableTime,
      );
      
      setState(() {
        _aiSuggestions = suggestions;
        _isLoading = false;
        _currentStep = 3;
      });
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get suggestions. Please try again.')),
        );
      }
    }
  }

  Future<void> _addSuggestedHabit(Map<String, dynamic> suggestion) async {
    await _habitService.addHabit(
      suggestion['title'],
      category: suggestion['category'] ?? 'General',
      iconEmoji: suggestion['icon'] ?? '✅',
      priority: suggestion['priority'] ?? 3,
    );
    
    widget.onHabitAdded();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${suggestion['title']} added to your habits! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _sendChatMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatMessages.add({'sender': 'user', 'message': message});
      _chatController.clear();
    });

    // Show typing indicator
    setState(() {
      _chatMessages.add({'sender': 'ai', 'message': '🤖 Thinking...'});
    });

    // Get AI response
    final context = 'User has ${_existingHabits.length} existing habits. Goal: $_goal. Lifestyle: $_lifestyle.';
    final response = await AIHabitService.chatWithAI(message, context);
    
    setState(() {
      // Remove typing indicator
      _chatMessages.removeLast();
      // Add actual response
      _chatMessages.add({'sender': 'ai', 'message': response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AI Habit Coach'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(_showChat ? Icons.lightbulb : Icons.chat),
            onPressed: () {
              setState(() {
                _showChat = !_showChat;
              });
            },
          ),
        ],
      ),
      body: _showChat ? _buildChatInterface() : _buildSuggestionsInterface(),
    );
  }

  Widget _buildSuggestionsInterface() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildLifestyleStep(),
        _buildGoalStep(),
        _buildTimeStep(),
        _buildSuggestionsStep(),
      ],
    );
  }

  Widget _buildLifestyleStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'How would you describe your current lifestyle?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'This helps me suggest habits that fit your daily routine.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ..._buildChoiceButtons([
            {'title': 'Sedentary', 'subtitle': 'Mostly sitting, limited physical activity', 'icon': '🪑'},
            {'title': 'Moderately Active', 'subtitle': 'Some exercise, balanced routine', 'icon': '🚶'},
            {'title': 'Very Active', 'subtitle': 'Regular exercise, active lifestyle', 'icon': '🏃'},
          ], _lifestyle, (value) {
            setState(() {
              _lifestyle = value;
            });
            _nextStep();
          }),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'What\'s your primary goal?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'I\'ll tailor suggestions to help you achieve what matters most.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ..._buildChoiceButtons([
            {'title': 'Better Health', 'subtitle': 'Physical wellness and energy', 'icon': '💪'},
            {'title': 'Mental Wellbeing', 'subtitle': 'Stress reduction and mindfulness', 'icon': '🧘'},
            {'title': 'Personal Growth', 'subtitle': 'Learning and skill development', 'icon': '🌱'},
            {'title': 'Work Performance', 'subtitle': 'Productivity and focus', 'icon': '🎯'},
          ], _goal, (value) {
            setState(() {
              _goal = value;
            });
            _nextStep();
          }),
        ],
      ),
    );
  }

  Widget _buildTimeStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.schedule, size: 64, color: Colors.purple),
          const SizedBox(height: 24),
          const Text(
            'How much time can you dedicate daily?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'I\'ll suggest habits that fit your available time.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ..._buildChoiceButtons([
            {'title': '10-15 minutes', 'subtitle': 'Quick daily habits', 'icon': '⏱️'},
            {'title': '20-30 minutes', 'subtitle': 'Moderate commitment', 'icon': '⏰'},
            {'title': '45+ minutes', 'subtitle': 'Deep practice sessions', 'icon': '🕐'},
          ], _availableTime.toString(), (value) {
            setState(() {
              _availableTime = value == '10-15 minutes' ? 15 : 
                            value == '20-30 minutes' ? 30 : 45;
            });
            _nextStep();
          }),
        ],
      ),
    );
  }

  Widget _buildSuggestionsStep() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('AI is analyzing your profile...', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Creating personalized suggestions ✨', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Recommendations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Personalized for your ${_lifestyle.toLowerCase()} lifestyle',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _aiSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _aiSuggestions[index];
                return _buildSuggestionCard(suggestion);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChoiceButtons(
    List<Map<String, String>> choices,
    String selectedValue,
    Function(String) onSelect,
  ) {
    return choices.map((choice) {
      final isSelected = selectedValue == choice['title'];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelect(choice['title']!),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(choice['icon']!, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          choice['title']!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          choice['subtitle']!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blue, size: 28),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    suggestion['icon'] ?? '✅',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion['title'] ?? 'New Habit',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          suggestion['category'] ?? 'General',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _addSuggestedHabit(suggestion),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              suggestion['description'] ?? 'A great habit to build.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            if (suggestion['reason'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion['reason'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[400]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: const Row(
                children: [
                  Text('🤖', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Habit Coach',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ask me anything about building better habits!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _chatMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        const Text(
                          'Hi! I\'m your AI Habit Coach',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask me about habit building, motivation,\nor anything related to personal growth!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = _chatMessages[index];
                      final isUser = message['sender'] == 'user';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['message']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Ask about habits...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendChatMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendChatMessage,
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}