import 'dart:convert';
import 'package:anime_app/models/user_model.dart';
import 'package:anime_app/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final userService = ref.read(userServiceProvider);
      final result = await userService.login(email, password);
      final user = result['user'] as User;
      final token = result['token'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user.toJson()));

      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = const AsyncLoading();
    try {
      final userService = ref.read(userServiceProvider);
      final result = await userService.register(username, email, password);
      final user = result['user'] as User;
      final token = result['token'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user.toJson()));

      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    state = const AsyncData(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});