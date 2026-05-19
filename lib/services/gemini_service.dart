import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config.dart';

class GeminiService {
  final String endpoint = 'https://api.openai.com/v1/chat/completions';

  GeminiService();

  Future<Map<String, dynamic>> parseRequest(String userInput) async {
    final String prompt = '''
You are an intent parser for a tutor-finding app in Pakistan. Users write in Urdu, Roman Urdu, English or mixed. Extract: subject (Math/Physics/English/etc), location (Islamabad sector like G-13/F-11/I-8), urgency (low/medium/high), preferredTime, budgetLevel (low/medium/high), constraints (array). Set confidenceScore 0.0-1.0. If location or subject is unclear, set needsConfirmation true and write a polite confirmationQuestion in Roman Urdu. Return ONLY JSON, no other text.
''';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'system', 'content': prompt},
            {'role': 'user', 'content': userInput}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          return jsonDecode(content.trim()) as Map<String, dynamic>;
        }
      } else {
        final errorMsg = 'OpenAI API Error: ${response.statusCode} - ${response.body}';
        debugPrint(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Exception in GeminiService (OpenAI): $e');
      throw Exception('Exception in GeminiService (OpenAI): $e');
    }

    // Fallback response
    return {
      'subject': null,
      'location': null,
      'urgency': null,
      'preferredTime': null,
      'budgetLevel': null,
      'constraints': [],
      'confidenceScore': 0.0,
      'needsConfirmation': true,
      'confirmationQuestion': 'Mujhe theek se samajh nahi aaya. Kya aap thora wazeh kar sakte hain?'
    };
  }
}
