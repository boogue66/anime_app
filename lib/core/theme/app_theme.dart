import 'package:flutter/material.dart';

class AppTheme {
  static const Color secondaryOrange = Color(0xFFFF8C42);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF5F5F5);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF616161);

  static ThemeData getTheme(Color primaryColor, {bool isDarkMode = true}) {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    final primaryTextColor = isDarkMode ? textPrimaryDark : textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? textSecondaryDark
        : textSecondaryLight;
    final backgroundColor = isDarkMode ? darkBackground : lightBackground;
    final cardColor = isDarkMode ? cardDark : cardLight;

    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: secondaryOrange,
        surface: cardColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: primaryTextColor,
        brightness: brightness,
        error: Colors.red,
        onError: Colors.white,
      ),
      brightness: brightness,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      iconTheme: IconThemeData(color: primaryColor),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        titleLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        titleMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        bodyLarge: TextStyle(fontSize: 16.0, color: primaryTextColor),
        bodyMedium: TextStyle(fontSize: 14.0, color: secondaryTextColor),
        bodySmall: TextStyle(fontSize: 12.0, color: secondaryTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: secondaryTextColor),
        labelStyle: TextStyle(color: secondaryTextColor),
      ),
      dividerTheme: DividerThemeData(
        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
