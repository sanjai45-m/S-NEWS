import 'package:shared_preferences/shared_preferences.dart';

class SharedDarkTheme {
  static const setValue = "Fixed";

  setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(setValue, value);
  }

 Future<bool?> getDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
   return  prefs.getBool(setValue);
  }
}
