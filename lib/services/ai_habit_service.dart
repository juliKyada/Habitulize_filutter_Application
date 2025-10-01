import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AIHabitService {
  // API configuration is now managed in a separate secure file
  
  // Fallback suggestions when API is not available
  static const List<Map<String, dynamic>> _fallbackSuggestions = [
    {
      'title': 'Morning Meditation',
      'description': 'Start your day with 10 minutes of mindfulness meditation',
      'category': 'Mindfulness',
      'icon': '🧘',
      'priority': 4,
      'reason': 'Meditation reduces stress and improves focus throughout the day'
    },
    {
      'title': 'Daily Exercise',
      'description': '30 minutes of physical activity',
      'category': 'Fitness',
      'icon': '🏃',
      'priority': 5,
      'reason': 'Regular exercise boosts energy, improves mood, and enhances overall health'
    },
    {
      'title': 'Read for Learning',
      'description': 'Read 20 pages of a book daily',
      'category': 'Learning',
      'icon': '📚',
      'priority': 3,
      'reason': 'Daily reading expands knowledge and improves cognitive function'
    },
    {
      'title': 'Hydration Goal',
      'description': 'Drink 8 glasses of water',
      'category': 'Health',
      'icon': '💧',
      'priority': 4,
      'reason': 'Proper hydration improves energy, skin health, and brain function'
    },
    {
      'title': 'Gratitude Journal',
      'description': 'Write 3 things you\'re grateful for',
      'category': 'Mindfulness',
      'icon': '📝',
      'priority': 3,
      'reason': 'Gratitude practice improves mental health and life satisfaction'
    },
    {
      'title': 'Quality Sleep',
      'description': 'Get 7-8 hours of sleep',
      'category': 'Health',
      'icon': '😴',
      'priority': 5,
      'reason': 'Quality sleep is essential for physical recovery and mental performance'
    },
  ];

  // Get AI-powered habit suggestions based on user profile
  static Future<List<Map<String, dynamic>>> getPersonalizedSuggestions({
    List<String> existingHabits = const [],
    String userGoal = '',
    String lifestyle = '',
    int availableTime = 30,
  }) async {
    try {
      print('🚀 Starting getPersonalizedSuggestions...');
      print('🔧 API configured: ${APIConfig.isConfigured}');
      print('🔧 AI enabled: ${APIConfig.enableAIFeatures}');
      print('🔧 API key starts with AIza: ${APIConfig.geminiApiKey.startsWith('AIza')}');
      
      if (!APIConfig.isConfigured || !APIConfig.enableAIFeatures) {
        print('⚠️ API not configured or disabled, using fallback suggestions');
        return _getEnhancedFallbackSuggestions(existingHabits);
      }

      print('🌐 Making API call...');
      final response = await _callAIAPI(existingHabits, userGoal, lifestyle, availableTime);
      if (response != null) {
        print('✅ Got API response, parsing...');
        final parsed = _parseAIResponse(response);
        if (parsed.isNotEmpty) {
          print('✅ Successfully parsed ${parsed.length} suggestions from API');
          return parsed;
        } else {
          print('⚠️ Failed to parse API response, using fallback');
        }
      } else {
        print('❌ API call returned null, using fallback');
      }
    } catch (e) {
      print('❌ Exception in getPersonalizedSuggestions: $e');
    }
    
    // Fallback to smart suggestions
    print('🔄 Using fallback suggestions');
    return _getEnhancedFallbackSuggestions(existingHabits);
  }

  static Future<String?> _callAIAPI(
    List<String> existingHabits,
    String userGoal,
    String lifestyle,
    int availableTime,
  ) async {
    try {
      final prompt = _buildPrompt(existingHabits, userGoal, lifestyle, availableTime);
      print('📝 Prompt built: ${prompt.substring(0, 100)}...');
      
      final url = '${APIConfig.geminiBaseUrl}?key=${APIConfig.geminiApiKey}';
      print('🌐 Making request to: ${url.substring(0, 100)}...');
      
      final response = await http.post(
        Uri.parse(url),
        headers: APIConfig.geminiHeaders,
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are a helpful habit coach that provides personalized habit suggestions in JSON format.\n\n$prompt'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      ).timeout(Duration(seconds: APIConfig.aiTimeoutSeconds));

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Response received successfully');
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        print('📄 Content length: ${content.length} characters');
        return content;
      } else {
        print('❌ HTTP Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception in _callAIAPI: $e');
      return null;
    }
  }

  static String _buildPrompt(
    List<String> existingHabits,
    String userGoal,
    String lifestyle,
    int availableTime,
  ) {
    return '''
Please suggest 5 personalized habits based on the following user profile:

Existing Habits: ${existingHabits.join(', ')}
Goal: $userGoal
Lifestyle: $lifestyle
Available Time: $availableTime minutes per day

Return suggestions as a JSON array with this structure:
[
  {
    "title": "Habit Name",
    "description": "Brief description",
    "category": "Category",
    "icon": "emoji",
    "priority": 1-5,
    "reason": "Why this habit is beneficial"
  }
]

Focus on habits that complement existing ones and are achievable given the time constraint.
''';
  }

  static List<Map<String, dynamic>> _parseAIResponse(String response) {
    try {
      // Extract JSON from AI response
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final List<dynamic> suggestions = jsonDecode(jsonStr);
        return suggestions.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Failed to parse AI response: $e');
    }
    
    return [];
  }

  static List<Map<String, dynamic>> _getEnhancedFallbackSuggestions(List<String> existingHabits) {
    // Filter out habits user already has
    final available = _fallbackSuggestions.where((suggestion) {
      return !existingHabits.any((existing) => 
        existing.toLowerCase().contains(suggestion['title'].toLowerCase().split(' ')[0]));
    }).toList();
    
    // Shuffle and return up to 5 suggestions
    available.shuffle(Random());
    return available.take(5).toList();
  }

  // Get AI-powered habit advice
  static Future<String> getHabitAdvice(String habitName, int currentStreak, int totalCompletions) async {
    try {
      if (APIConfig.isConfigured && APIConfig.enableAIFeatures) {
        final advice = await _getAIAdvice(habitName, currentStreak, totalCompletions);
        if (advice != null) return advice;
      }
    } catch (e) {
      print('AI Advice Error: $e');
    }
    
    return _getFallbackAdvice(habitName, currentStreak);
  }

  static Future<String?> _getAIAdvice(String habitName, int currentStreak, int totalCompletions) async {
    final prompt = '''
You are an encouraging habit coach who provides brief, actionable advice.

Provide encouraging and actionable advice for someone working on this habit:

Habit: $habitName
Current Streak: $currentStreak days
Total Completions: $totalCompletions

Give 2-3 sentences of personalized motivation and practical tips. Be encouraging and specific.
''';

    final response = await http.post(
      Uri.parse('${APIConfig.geminiBaseUrl}?key=${APIConfig.geminiApiKey}'),
      headers: APIConfig.geminiHeaders,
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': prompt
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 150,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'].trim();
    }
    
    return null;
  }

  static String _getFallbackAdvice(String habitName, int currentStreak) {
    final adviceMap = {
      'exercise': [
        "Great job on your $currentStreak day streak! 💪 Remember, consistency beats intensity. Even 10 minutes counts!",
        "Your body is getting stronger with each workout! Keep building that momentum. 🏃‍♂️",
        "Exercise is your daily dose of medicine. You're investing in your future self! 🌟"
      ],
      'read': [
        "Amazing reading streak of $currentStreak days! 📚 You're literally growing your brain with each page.",
        "Knowledge compounds daily. Keep feeding your mind with great ideas! 🧠✨",
        "Every book opens new worlds. Your dedication to learning is inspiring! 📖"
      ],
      'meditat': [
        "Your mindfulness practice is building inner peace day by day. 🧘‍♀️ Keep cultivating that calm.",
        "Meditation is training your mind muscle. $currentStreak days of mental fitness! 🧠💪",
        "In a busy world, you're choosing stillness. That's true wisdom. 🌸"
      ],
      'water': [
        "Hydration hero! 💧 Your body thanks you for those $currentStreak days of proper hydration.",
        "Water is life! Keep flowing towards better health. 🌊",
        "Clear mind, clear body. You're doing amazing with your water intake! ✨"
      ],
    };

    final habitLower = habitName.toLowerCase();
    for (final key in adviceMap.keys) {
      if (habitLower.contains(key)) {
        final advice = adviceMap[key]!;
        return advice[currentStreak % advice.length];
      }
    }

    return "You're building something amazing with this $currentStreak day streak! 🌟 Keep going, every day counts towards becoming your best self!";
  }

  // Chat with AI about habits
  static Future<String> chatWithAI(String message, String context) async {
    print('🚀 Starting chatWithAI...');
    print('🔧 API configured: ${APIConfig.isConfigured}');
    print('🔧 AI enabled: ${APIConfig.enableAIFeatures}');
    
    try {
      if (APIConfig.isConfigured && APIConfig.enableAIFeatures) {
        print('🌐 Attempting API call...');
        final response = await _chatAPI(message, context);
        if (response != null && response.isNotEmpty) {
          print('✅ Got AI response: ${response.substring(0, response.length > 50 ? 50 : response.length)}...');
          return response;
        } else {
          print('⚠️ API returned null or empty response');
        }
      } else {
        print('⚠️ API not configured or disabled');
      }
    } catch (e) {
      print('❌ AI Chat Error: $e');
    }
    
    print('🔄 Using fallback response');
    return _getFallbackChatResponse(message);
  }

  static Future<String?> _chatAPI(String message, String context) async {
    print('🤖 Making Gemini AI API call...');
    print(' API Key configured: ${APIConfig.isConfigured}');
    print('💬 Message: $message');

    final prompt = '''You are a friendly and knowledgeable habit coach. Help users build better habits with encouragement and practical advice. Keep responses concise and actionable.

Context: $context

User Question: $message

Please provide a helpful, encouraging response:''';

    // Try main endpoint first
    try {
      print('📍 Trying main API URL: ${APIConfig.geminiBaseUrl}');
      
      final response = await http.post(
        Uri.parse('${APIConfig.geminiBaseUrl}?key=${APIConfig.geminiApiKey}'),
        headers: APIConfig.geminiHeaders,
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 200,
          }
        }),
      ).timeout(Duration(seconds: APIConfig.aiTimeoutSeconds));

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'].trim();
        print('✅ Gemini AI Response received successfully');
        return aiResponse;
      } else {
        print('❌ Main endpoint failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Main endpoint exception: $e');
    }

    // Try alternative endpoints
    for (int i = 0; i < APIConfig.alternativeEndpoints.length; i++) {
      try {
        final endpoint = APIConfig.alternativeEndpoints[i];
        print('🔄 Trying alternative endpoint ${i + 1}: $endpoint');
        
        final response = await http.post(
          Uri.parse('$endpoint?key=${APIConfig.geminiApiKey}'),
          headers: APIConfig.geminiHeaders,
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text': prompt
                  }
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 200,
            }
          }),
        ).timeout(Duration(seconds: APIConfig.aiTimeoutSeconds));

        print('📡 Alternative ${i + 1} status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final aiResponse = data['candidates'][0]['content']['parts'][0]['text'].trim();
          print('✅ Alternative endpoint ${i + 1} worked!');
          return aiResponse;
        } else {
          print('❌ Alternative ${i + 1} failed: ${response.statusCode}');
        }
      } catch (e) {
        print('💥 Alternative ${i + 1} exception: $e');
      }
    }

    print('🚫 All API endpoints failed');
    return null;
  }

  static String _getFallbackChatResponse(String message) {
    final messageLower = message.toLowerCase();
    
    if (messageLower.contains('motivat') || messageLower.contains('encourage')) {
      final responses = [
        "You've got this! 💪 Every small step you take is building towards your bigger goals. I believe in your ability to create positive change!",
        "Your dedication to improving yourself is inspiring! 🌟 Remember, every expert was once a beginner. Keep moving forward!",
        "Progress isn't always visible, but it's always happening! 🚀 Trust the process and celebrate every small victory along the way.",
      ];
      return responses[DateTime.now().millisecond % responses.length];
    } else if (messageLower.contains('streak') || messageLower.contains('consistent')) {
      final responses = [
        "Consistency is the key to success! 🔑 Focus on showing up every day, even if it's just for a few minutes. Small daily actions create big results over time.",
        "Streaks are built one day at a time! 📅 Don't aim for perfection - aim for progress. Missing one day doesn't break your momentum, giving up does!",
        "The magic happens in the repetition! 🎯 Each day you show up, you're rewiring your brain and building your future self.",
      ];
      return responses[DateTime.now().millisecond % responses.length];
    } else if (messageLower.contains('difficult') || messageLower.contains('hard')) {
      final responses = [
        "I understand it can be challenging! 🤗 Try starting smaller or linking your habit to something you already do. What matters most is progress, not perfection.",
        "Difficult times build strong habits! 💎 Consider lowering the bar - can you do 50% of your habit? Even 10%? Something is always better than nothing.",
        "Challenges are opportunities in disguise! 🎭 What if you rewarded yourself for attempting, not just completing? Progress deserves celebration!",
      ];
      return responses[DateTime.now().millisecond % responses.length];
    } else if (messageLower.contains('time') || messageLower.contains('busy')) {
      final responses = [
        "Time is precious, I get it! ⏰ Try the 2-minute rule - start with just 2 minutes of your habit. Often, starting is the hardest part!",
        "Busy schedules need smart habits! 🧠 Can you stack this habit with something you already do? Like meditation while coffee brews?",
        "Even superheroes have time limits! 🦸‍♀️ Focus on micro-habits - they're small but mighty, and they fit into any schedule!",
      ];
      return responses[DateTime.now().millisecond % responses.length];
    } else if (messageLower.contains('help') || messageLower.contains('advice') || messageLower.contains('tip')) {
      final responses = [
        "Here's a pro tip: Stack your new habit after an existing one! 🔗 Like 'After I brush my teeth, I'll do 5 pushups.' Your brain loves patterns!",
        "Try the 1% rule! 📈 Improve just 1% each day. It seems small, but after a year, you'll be 37 times better! Math is magical! ✨",
        "Environment shapes behavior! 🏠 Make good habits obvious (put your workout clothes out) and bad habits invisible (hide the snacks)!",
      ];
      return responses[DateTime.now().millisecond % responses.length];
    } else {
      final responses = [
        "Thanks for sharing! 😊 Remember, building habits is a journey. Be patient with yourself and celebrate every small win along the way!",
        "Great question! 🤔 The fact that you're thinking about habits means you're already on the right path. Keep that curiosity alive!",
        "I love your commitment to growth! 🌱 Every conversation about habits is a step toward becoming your best self. What's your next move?",
        "Your future self is cheering you on right now! 📣 They know that the small choices you make today are creating their amazing life tomorrow!",
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
  }
}