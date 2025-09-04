// ignore_for_file: avoid_print

import 'package:anime_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/models/user_model.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  // WARNING: This approach is highly inefficient and insecure for production.
  // It fetches all users to check existence or perform login.
  // A proper backend should have dedicated endpoints for these operations.

  Future<bool> checkEmailExists(String email) async {
    return await _apiService.checkEmail(email);
  }

  Future<User?> login(String email) async {
    final userMap = await _apiService.login(email);

    if (userMap != null) {
      return User.fromJson(userMap);
    }
    return null;
  }

  Future<User?> register(String username, String email) async {
    final userExists = await checkEmailExists(email);
    if (userExists) {
      print('Register error: Email already in use.');
      return null;
    }

    final response = await _apiService.createUser(username, email);
    if (response.containsKey('error')) {
      print('Register error: ${response['error']}');
      throw Exception(response['error'] ?? 'Failed to register');
    }

    if (response.containsKey('data') && response['data']['user'] != null) {
      return User.fromJson(response['data']['user']);
    } else {
      print('Register error: Unexpected response structure.');
      throw Exception('Failed to register due to unexpected response.');
    }
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserService(apiService);
});
