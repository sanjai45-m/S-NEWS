import 'package:flutter/material.dart';

import '../constant_classes/shared_darkTheme.dart';



class DarkThemeProvider with ChangeNotifier {
  final sharedDarkThemeprefs = SharedDarkTheme();
  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  set darkThemes(bool value) {
    _darkTheme = value;
    sharedDarkThemeprefs.setDarkTheme(value);
    notifyListeners();
  }
}
