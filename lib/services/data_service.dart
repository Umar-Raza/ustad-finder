import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/tutor.dart';

class DataService {
  Future<List<Tutor>> loadTutors() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/tutors.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((jsonItem) => Tutor.fromJson(jsonItem)).toList();
    } catch (e) {
      debugPrint('Error loading tutors: $e');
      return [];
    }
  }
}
