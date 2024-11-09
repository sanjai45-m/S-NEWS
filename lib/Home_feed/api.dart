import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'new_details/news.dart';

class Api {
  final apikey = 'key';

  Future<List<Articles>?> getFromJson() async {
    final url = Uri.parse(
        'https://newsapi.org/v2/everything?q=latest&apiKey=$apikey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['articles'] as List;

        // Filter out articles with null or '[Removed]' values
        final filteredData = data.map((e) => Articles.fromJson(e)).where((article) {
          return article.title != null &&
              article.urlToImage != null &&
              article.content != null &&
              article.title != '[Removed]' &&
              article.urlToImage != '[Removed]' &&
              article.content != '[Removed]';
        }).toList();

        return filteredData;
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