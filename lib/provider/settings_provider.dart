import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String userPhoneNumber = '';

  Future<void> fetchUserPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userPhoneNumber = prefs.getString('phoneNumber') ?? '';
    notifyListeners();
  }
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('phoneNumber'); // Clear phone number
    userPhoneNumber = ''; // Clear local state
    notifyListeners(); // Notify listeners about changes
  }
}
