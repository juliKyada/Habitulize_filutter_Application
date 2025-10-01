// Quick API Test - Run this to check if your Gemini API key works
// Save this as test_api.dart and run: dart test_api.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  const apiKey = 'AIzaSyB7LtKBCQkJbm9OhAw25BqYdYyhDMhNops';
  const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';
  
  final client = HttpClient();
  
  try {
    print('🚀 Testing Gemini API...');
    print('🔑 API Key: ${apiKey.substring(0, 12)}...');
    print('🌐 URL: $url');
    
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': 'Hello! Please respond with "API is working!" if you can see this message.'}
          ]
        }
      ]
    });
    
    request.write(body);
    final response = await request.close();
    
    print('📡 Status Code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      print('✅ Success! Response:');
      print(responseBody);
      
      final data = jsonDecode(responseBody);
      final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
      print('🤖 AI Response: $aiResponse');
      
    } else {
      final errorBody = await response.transform(utf8.decoder).join();
      print('❌ Error ${response.statusCode}:');
      print(errorBody);
      
      if (response.statusCode == 403) {
        print('\n💡 Possible solutions:');
        print('• Your API key might not have Gemini API access enabled');
        print('• Go to https://aistudio.google.com/app/apikey');
        print('• Make sure Gemini API is enabled for your project');
      }
    }
    
  } catch (e) {
    print('💥 Exception: $e');
  } finally {
    client.close();
  }
}