// ignore_for_file: avoid_print

import 'package:anime_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/models/user_model.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.login(email, password);

    if (response.containsKey('error')) {
      throw Exception(response['error']);
    }

    final user = User.fromJson(response['data']['user']);
    final token = response['token'];

    return {'user': user, 'token': token};
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await _apiService.signup(username, email, password);

    if (response.containsKey('error')) {
      throw Exception(response['error']);
    }
    
    final user = User.fromJson(response['data']['user']);
    final token = response['token'];

    return {'user': user, 'token': token};
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserService(apiService);
});