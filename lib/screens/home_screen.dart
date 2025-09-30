import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/badge.dart' as HabitBadgeModel;
import '../models/user_stats.dart';
import '../services/habit_service.dart';
import 'add_habit_screen.dart';
import 'suggestions_screen.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  UserStats _userStats = UserStats();
  bool _isLoading = true;
  late AnimationController _motivationController;
  late AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _motivationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadHabits();
  }

  @override
  void dispose() {
    _motivationController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });
    final habits = await _habitService.getHabits();
    final stats = await _habitService.getUserStats();
    setState(() {
      _habits = habits;
      _userStats = stats;
      _isLoading = false;
    });
    _motivationController.forward();
  }

  Future<void> _toggleHabitCompletion(Habit habit) async {
    if (!habit.isCompletedToday) {
      final newBadges = await _habitService.completeHabit(habit.id);
      
      // Show badge celebration if new badges were earned
      if (newBadges.isNotEmpty) {
        _showBadgeCelebration(newBadges);
      }
      
      // Show completion celebration
      _showCompletionCelebration(habit);
      
      _loadHabits();
    }
  }

  void _showBadgeCelebration(List<HabitBadgeModel.HabitBadge> badges) {
    _badgeController.reset();
    _badgeController.forward();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 New Achievement!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: badges.map<Widget>((badge) => ListTile(
            leading: Text(badge.iconEmoji, style: const TextStyle(fontSize: 32)),
            title: Text(badge.name),
            subtitle: Text(badge.description),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _showCompletionCelebration(Habit habit) {
    final messages = [
      "Great job! 🎉",
      "Keep it up! 💪",
      "You're on fire! 🔥",
      "Fantastic! ⭐",
      "Well done! 👏",
    ];
    
    final message = messages[DateTime.now().millisecond % messages.length];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message ${habit.name} completed!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _deleteHabit(String id) async {
    await _habitService.deleteHabit(id);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    final completedToday = _habits.where((h) => h.isCompletedToday).length;
    final totalHabits = _habits.length;
    final progressPercentage = totalHabits > 0 ? (completedToday / totalHabits) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Habitulize', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(
              _habitService.getTodaysQuote(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AchievementsScreen(userStats: _userStats),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy),
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

        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // User Stats Dashboard
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.blue[400]!, Colors.blue[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Level ${_userStats.level}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _userStats.levelTitle,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '🏆',
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Progress Bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'XP: ${_userStats.experience}/${_userStats.experienceForNextLevel}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        '${(_userStats.progressToNextLevel * 100).toInt()}%',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _userStats.progressToNextLevel,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('🔥', '${_userStats.currentLongestStreak}', 'Best Streak'),
                                  _buildStatItem('🎯', '$completedToday/$totalHabits', 'Today'),
                                  _buildStatItem('🏅', '${_userStats.earnedBadges.length}', 'Badges'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Today's Progress
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Today\'s Progress',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${(progressPercentage * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: progressPercentage == 1.0 ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: progressPercentage,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressPercentage == 1.0 ? Colors.green : Colors.orange,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              progressPercentage == 1.0 
                                  ? '🎉 All habits completed today!'
                                  : '$completedToday of $totalHabits habits completed',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Habits List
                  if (_habits.isEmpty)
                    Container(
                      margin: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.psychology, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No habits yet!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start your journey by adding your first habit.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddHabitScreen(
                                    onHabitAdded: () => _loadHabits(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Habit'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        final habit = _habits[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutBack,
                          child: ModernHabitCard(
                            habit: habit,
                            onToggle: () => _toggleHabitCompletion(habit),
                            onDelete: () => _deleteHabit(habit.id),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddHabitScreen(
                onHabitAdded: () => _loadHabits(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
        backgroundColor: Colors.orange[400],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ModernHabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ModernHabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<ModernHabitCard> createState() => _ModernHabitCardState();
}

class _ModernHabitCardState extends State<ModernHabitCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.blue[300]!;
      case 3:
        return Colors.orange[400]!;
      case 4:
        return Colors.red[400]!;
      case 5:
        return Colors.purple[400]!;
      default:
        return Colors.orange[400]!;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium-';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Critical';
      default:
        return 'Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.habit.isCompletedToday;
    final priorityColor = _getPriorityColor(widget.habit.priority);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: isCompleted ? 2 : 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isCompleted
                      ? LinearGradient(
                          colors: [Colors.green[50]!, Colors.green[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: Border.all(
                    color: priorityColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Habit Icon and Completion Button
                          GestureDetector(
                            onTapDown: (_) => _scaleController.forward(),
                            onTapUp: (_) {
                              _scaleController.reverse();
                              widget.onToggle();
                            },
                            onTapCancel: () => _scaleController.reverse(),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isCompleted ? Colors.green : priorityColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isCompleted ? Colors.green : priorityColor).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                                  : Text(
                                      widget.habit.iconEmoji,
                                      style: const TextStyle(fontSize: 24),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Habit Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.habit.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    color: isCompleted ? Colors.grey : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: priorityColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getPriorityText(widget.habit.priority),
                                        style: TextStyle(
                                          color: priorityColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.habit.category,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.grey[400],
                            onPressed: () => _showDeleteDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Streak and Stats Row
                      Row(
                        children: [
                          _buildStatChip('🔥', '${widget.habit.streak}', 'Current'),
                          const SizedBox(width: 8),
                          _buildStatChip('🏆', '${widget.habit.bestStreak}', 'Best'),
                          const SizedBox(width: 8),
                          _buildStatChip('📊', '${widget.habit.totalCompletions}', 'Total'),
                          const Spacer(),
                          Text(
                            '${(widget.habit.completionRate * 100).toInt()}% rate',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text('Are you sure you want to delete "${widget.habit.name}"?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}