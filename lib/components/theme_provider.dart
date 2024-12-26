import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('dark_theme') ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark_theme', _isDarkTheme);
    notifyListeners();
  }

  Color get primaryColor => _isDarkTheme ? const Color(0xFF004D40) : const Color(0xFF01BF6B);
  Color get iconColor => _isDarkTheme ? Colors.white : Colors.black;
  Color get backgroundColor => _isDarkTheme ? const Color(0xFF121212) : Colors.white;
  Color get navBouton => _isDarkTheme ? Colors.white : Colors.black;
  Color get selectedLabelColor => const Color(0xFF01BF6B);
  Color get unselectedLabelColor => _isDarkTheme ? Colors.white : Colors.black;
}