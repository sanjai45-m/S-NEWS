import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _phoneNumber = '';
  String _firstName = '';
  String _email = '';
  String _pin = '';
  String? _profileImageUrl;
  bool isTyping = false;
  String? _fcmToken; // Add this line


  String get phoneNumber => _phoneNumber;
  String get firstName => _firstName;
  String get email => _email;
  String get pin => _pin;
  String? get profileImageUrl => _profileImageUrl;
  String? get fcmToken => _fcmToken; // Add this line
  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    savePhoneNumberToPrefs(phoneNumber);
    notifyListeners();
  }

  Future<void> savePhoneNumberToPrefs(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phoneNumber', phoneNumber);
  }

  Future<void> loadPhoneNumberFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _phoneNumber = prefs.getString('phoneNumber') ?? '';
  }

  Future<void> fetchUserData() async {
    await loadPhoneNumberFromPrefs();
    if (_phoneNumber.isNotEmpty) {
      final String userUrl = 'Database Url';
      try {
        final response = await http.get(Uri.parse(userUrl));
        final data = json.decode(response.body);
        _firstName = data['firstName'] ?? '';
        _email = data['email'] ?? '';
        _pin = data['pin'] ?? '';
        _profileImageUrl = data['profileImageUrl'];

        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> updateUserData(String newFirstName, String newEmail, String newPin) async {
    final String userUrl = 'url';
    final updatedData = {
      'firstName': newFirstName,
      'email': newEmail,
      'pin': newPin,
      'profileImageUrl': _profileImageUrl,
    };

    try {
      await http.put(
        Uri.parse(userUrl),
        body: json.encode(updatedData),
      );
      _firstName = newFirstName;
      _email = newEmail;
      _pin = newPin;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> changePassword(String currentPin, String newPin) async {
    if (currentPin != _pin) {
      return false; // Current PIN doesn't match
    }

    final String userUrl = 'Url';
    final updatedData = {
      'firstName': _firstName,
      'email': _email,
      'pin': newPin,
      'profileImageUrl': _profileImageUrl,
    };

    try {
      await http.put(
        Uri.parse(userUrl),
        body: json.encode(updatedData),
      );
      _pin = newPin; // Update the local PIN
      notifyListeners();
      return true;
    } catch (error) {
      rethrow;
    }
  }

  void setProfileImageUrl(String newProfileImageUrl) {
    _profileImageUrl = newProfileImageUrl;
    notifyListeners();
  }

  Future<void> updateProfileImage(String newProfileImageUrl) async {
    final phone = _phoneNumber;
    final url = 'Url';

    final response = await http.patch(
      Uri.parse(url),
      body: json.encode({
        'profileImageUrl': newProfileImageUrl,
      }),
    );

    if (response.statusCode == 200) {
      setProfileImageUrl(newProfileImageUrl);
    } else {
      throw Exception('Failed to update profile image');
    }
  }


  void setTypingStatus(bool typing) {
    isTyping = typing;
    notifyListeners();
  }

  void setFcmToken(String token) { // Add this method
    _fcmToken = token;
    notifyListeners();
  }

}
