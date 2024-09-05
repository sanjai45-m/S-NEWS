import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/top_trending/top_trending_news.dart';
import 'package:http/http.dart' as http;
 
class TopTrendingNewsApiIndia {
  Future<List<Articles1>?> getFromJsonIndiaData() async {
    final url = Uri.parse('https://newsapi.org/v2/everything?q=&apiKey=API-Key');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['articles'];
        return data.map((e) => Articles1.fromJson(e)).toList();
      } else {
        throw Exception("Failed to Load Data");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to Load $e");
      }
      return null;
    }
  }
}
