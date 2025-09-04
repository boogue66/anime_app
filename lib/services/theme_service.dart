import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _primaryColorKey = 'primaryColor';
  static const String _isDarkModeKey = 'isDarkMode';

  Future<void> saveTheme(Color primaryColor, bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: deprecated_member_use
    await prefs.setInt(_primaryColorKey, primaryColor.value);
    await prefs.setBool(_isDarkModeKey, isDarkMode);
  }

  Future<ThemeData> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final primaryColorValue = prefs.getInt(_primaryColorKey);
    final isDarkMode = prefs.getBool(_isDarkModeKey) ?? true;

    final primaryColor = primaryColorValue != null
        ? Color(primaryColorValue)
        : const Color(0xFFF47521);

    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
    );
  }

  Future<Color> loadPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final primaryColorValue = prefs.getInt(_primaryColorKey);
    return primaryColorValue != null
        ? Color(primaryColorValue)
        : const Color(0xFFF47521);
  }

  Future<bool> loadIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? true;
  }
}
