import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PhoneNumberBookmark {
  static Future<bool> setBookmark(
      String phoneNumber, String url, String title) async {
    final String apiUrl = 'baseurl/users/$phoneNumber/bookmarks.json';

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({'url': url, 'title': title}),
      );

      return response.statusCode == 200;
    } catch (error) {
      if (kDebugMode) {
        print('Failed to set bookmark: $error');
      }
      return false;
    }
  }

  static Future<bool> removeBookmark(String phoneNumber, String url) async {
    final String apiUrl = 'baseurl/users/$phoneNumber/bookmarks.json';

    try {
      final http.Response response = await http.delete(
        Uri.parse(apiUrl),
        body: json.encode({'url': url}),
      );

      return response.statusCode == 200;
    } catch (error) {
      if (kDebugMode) {
        print('Failed to remove bookmark: $error');
      }
      return false;
    }
  }
}
