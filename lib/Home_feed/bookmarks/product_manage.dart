import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddBookMark {
  final String title;
  final String url;

  AddBookMark({required this.title, required this.url});

  factory AddBookMark.fromJson(Map<String, dynamic> json) {
    return AddBookMark(
      title: json['title'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
    };
  }
}

class ProductsManage with ChangeNotifier {
  //users

  //bookmark
  List<AddBookMark> _bookmarksList = [];
  int _bookmarkCount = 0;

  List<AddBookMark> get bookmarksList => _bookmarksList;

  int get bookmarkCount => _bookmarkCount;

  Future<void> fetchBookmarks(String phone) async {
    final response = await http.get(
      Uri.parse('Url'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data == null) {
        _bookmarksList = [];
      } else if (data is Map<String, dynamic>) {
        _bookmarksList = data.entries.map((entry) {
          return AddBookMark.fromJson(entry.value);
        }).toList();
      } else if (data is List<dynamic>) {
        _bookmarksList = data.map((item) {
          return AddBookMark.fromJson(item);
        }).toList();
      }
      _bookmarkCount = _bookmarksList.length;
      await saveBookmarkCountToFirebase(phone, _bookmarkCount);
      saveBookmarkCountToLocal(_bookmarkCount);
      notifyListeners();
    }
  }

  Future<void> addBookmark(String phone, AddBookMark bookmark) async {
    final response = await http.post(
      Uri.parse('Url'),
      body: jsonEncode(bookmark.toJson()),
    );
    if (response.statusCode == 200) {
      _bookmarksList.add(bookmark);
      _bookmarkCount = _bookmarksList.length;
      await saveBookmarkCountToFirebase(phone, _bookmarkCount);
      saveBookmarkCountToLocal(_bookmarkCount);
      notifyListeners();
    }
  }

  Future<void> removeBookmark(String phone, AddBookMark bookmark) async {
    //remove bookmark -  if the existing list has the url and title i unbookmarked then it remove from the database and list
    //put method updates the exisiting list
    final bookmarks =
        _bookmarksList.where((b) => b.url != bookmark.url).toList();
    final response = await http.put(
      Uri.parse('Url'),
      body: jsonEncode(bookmarks.map((b) => b.toJson()).toList()),
    );
    if (response.statusCode == 200) {
      _bookmarksList = bookmarks;
      _bookmarkCount = _bookmarksList.length;
      await saveBookmarkCountToFirebase(phone, _bookmarkCount);
      saveBookmarkCountToLocal(_bookmarkCount);
      notifyListeners();
    }
  }

  Future<void> loadBookmarkCount(String phone) async {
    final response = await http.get(
      Uri.parse('Url'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _bookmarkCount = data ?? 0;
      saveBookmarkCountToLocal(_bookmarkCount);
      notifyListeners();
    }
  }

  Future<void> saveBookmarkCountToFirebase(String phone, int count) async {
    await http.put(
      Uri.parse('Url'),
      body: jsonEncode(count),
    );
  }

  Future<void> saveBookmarkCountToLocal(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bookmarkCount', count);
  }

  //load bookmark count store in shared preference
  Future<void> loadBookmarkCountFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _bookmarkCount = prefs.getInt('bookmarkCount') ?? 0;
    notifyListeners();
  }

//showlogin users
}
