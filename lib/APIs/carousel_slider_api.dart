import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../top_trending/top_trending_news.dart';
import 'api.dart';
class CarouselSliderApi {
  Future<List<Articles1>?> getFromJsonApiImages() async {
    final apikey = Api().apikey;
    final url = Uri.parse(
        'https://newsapi.org/v2/everything?q=science&apiKey=$apikey');
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
