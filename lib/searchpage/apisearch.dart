import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:SNEWS/Home_feed/api.dart';
import 'package:http/http.dart' as http;
import 'package:SNEWS/top_trending/top_trending_news.dart';

class SourcesApi {
  final apikey = Api().apikey;
  Future<List<Articles1>?> getFromJsonFilters(String query) async {
    final url =
        Uri.parse('https://newsapi.org/v2/everything?q=$query&apiKey=$apikey');
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
