import 'package:anime_app/models/user_model.dart';
import 'package:anime_app/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    if (userEmail != null) {
      final userService = ref.read(userServiceProvider);
      final user = await userService.login(userEmail);
      return user;
    }
    return null;
  }

  Future<void> login(String email) async {
    state = const AsyncLoading();
    try {
      final userService = ref.read(userServiceProvider);
      final user = await userService.login(email);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email);
        state = AsyncData(user);
      } else {
        state = AsyncError('Login failed', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> register(String username, String email) async {
    state = const AsyncLoading();
    try {
      final userService = ref.read(userServiceProvider);
      final user = await userService.register(username, email);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email);
        state = AsyncData(user);
      } else {
        state = AsyncError('Registration failed', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> checkEmailExists(String email) async {
    final userService = ref.read(userServiceProvider);
    return await userService.checkEmailExists(email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    state = const AsyncData(null);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});
