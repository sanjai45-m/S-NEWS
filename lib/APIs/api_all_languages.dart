import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/languageNews/All_language.dart';
import 'package:http/http.dart' as http;

class ApiTamil {
  final String apiKey = 'API-Key';

  Future<List<News>?> getNewsByLanguage(String language) async {
    final url = Uri.parse(
        'https://newsapi.in/newsapi/news.php?key=$apiKey&category=$language');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (kDebugMode) {
          print("Response body: ${response.body}");
        }
        if (jsonData != null && jsonData['News'] != null) {
          final data = jsonData['News'] as List;
          return data.map((e) => News.fromJson(e)).toList();
        } else {
          if (kDebugMode) {
            print("JSON data or 'News' key is null");
          }
          return [];
        }
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load data: $e");
      }
      return null;
    }
  }
}
