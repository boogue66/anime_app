import 'package:anime_app/core/theme/app_theme.dart';
import 'package:anime_app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final ThemeData themeData;
  final Color primaryColor;
  final bool isDarkMode;

  ThemeState({
    required this.themeData,
    required this.primaryColor,
    required this.isDarkMode,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    Color? primaryColor,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      primaryColor: primaryColor ?? this.primaryColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  final ThemeService _themeService = ThemeService();

  ThemeNotifier()
      : super(
          ThemeState(
            themeData: AppTheme.getTheme(const Color(0xFFF47521)),
            primaryColor: const Color(0xFFF47521),
            isDarkMode: true,
          ),
        ) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final primaryColor = await _themeService.loadPrimaryColor();
    final isDarkMode = await _themeService.loadIsDarkMode();
    state = state.copyWith(
      primaryColor: primaryColor,
      isDarkMode: isDarkMode,
      themeData: AppTheme.getTheme(primaryColor, isDarkMode: isDarkMode),
    );
  }

  void setLightTheme() {
    state = state.copyWith(
      themeData: AppTheme.getTheme(state.primaryColor, isDarkMode: false),
      isDarkMode: false,
    );
    _themeService.saveTheme(state.primaryColor, false);
  }

  void setDarkTheme() {
    state = state.copyWith(
      themeData: AppTheme.getTheme(state.primaryColor, isDarkMode: true),
      isDarkMode: true,
    );
    _themeService.saveTheme(state.primaryColor, true);
  }

  void setPrimaryColor(Color color) {
    state = state.copyWith(
      primaryColor: color,
      themeData: AppTheme.getTheme(color, isDarkMode: state.isDarkMode),
    );
    _themeService.saveTheme(color, state.isDarkMode);
  }
}
