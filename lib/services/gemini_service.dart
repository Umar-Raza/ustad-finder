import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config.dart';

class GeminiService {
  final String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  GeminiService();

  Future<Map<String, dynamic>> parseRequest(String userInput) async {
    final String prompt = '''
You are an intent parser for a tutor-finding app in Pakistan. Users write in Urdu, Roman Urdu, English or mixed. Extract: subject (Math/Physics/English/etc), location (Islamabad sector like G-13/F-11/I-8), urgency (low/medium/high), preferredTime, budgetLevel (low/medium/high), constraints (array). Set confidenceScore 0.0-1.0. If location or subject is unclear, set needsConfirmation true and write a polite confirmationQuestion in Roman Urdu. Return ONLY JSON, no other text.

User Input: "$userInput"
''';

    try {
      final response = await http.post(
        Uri.parse('$endpoint?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List;
        if (candidates.isNotEmpty) {
          final content = candidates[0]['content']['parts'][0]['text'] as String;
          
          // Strip markdown fences if present
          String jsonStr = content.trim();
          if (jsonStr.startsWith('```json')) {
            jsonStr = jsonStr.substring(7);
          } else if (jsonStr.startsWith('```')) {
            jsonStr = jsonStr.substring(3);
          }
          if (jsonStr.endsWith('```')) {
            jsonStr = jsonStr.substring(0, jsonStr.length - 3);
          }
          
          return jsonDecode(jsonStr.trim()) as Map<String, dynamic>;
        }
      } else {
        debugPrint('Gemini API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in GeminiService: $e');
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
