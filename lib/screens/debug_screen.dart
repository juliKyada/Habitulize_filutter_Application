import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/ai_habit_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _testResult = 'Press the button to test AI connectivity';
  bool _isLoading = false;

  Future<void> _testAIConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing AI connection...';
    });

    try {
      final response = await AIHabitService.chatWithAI(
        'Hello! Just testing the connection.',
        'This is a connection test.',
      );

      setState(() {
        _isLoading = false;
        _testResult = 'Success! AI responded: "$response"';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _testResult = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini AI Debug Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemini AI Configuration Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard('API Key Configured', APIConfig.isConfigured ? '✅ Yes' : '❌ No'),
            _buildInfoCard('API Key Format', APIConfig.geminiApiKey.startsWith('AIza') ? '✅ Correct (Gemini)' : '❌ Wrong format'),
            _buildInfoCard('API Key Length', '${APIConfig.geminiApiKey.length} characters'),
            _buildInfoCard('API Key Preview', '${APIConfig.geminiApiKey.substring(0, 12)}...'),
            _buildInfoCard('AI Features Enabled', APIConfig.enableAIFeatures ? '✅ Yes' : '❌ No'),
            _buildInfoCard('API Base URL', APIConfig.geminiBaseUrl.substring(0, 50) + '...'),
            _buildInfoCard('AI Model', APIConfig.geminiModel),
            _buildInfoCard('Timeout', '${APIConfig.aiTimeoutSeconds}s'),
            const SizedBox(height: 24),
            const Text(
              'Connection Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAIConnection,
              child: _isLoading 
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Testing...'),
                    ],
                  )
                : const Text('Test AI Connection'),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _testResult,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Troubleshooting Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Make sure you have a Google Gemini API key (starts with "AIza")\n'
              '• Get your key from: https://aistudio.google.com/app/apikey\n'
              '• Verify your internet connection\n'
              '• Check if Gemini API is available in your region\n'
              '• The app will use smart fallbacks if AI is not available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}