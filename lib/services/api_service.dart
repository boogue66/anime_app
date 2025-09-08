// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that creates the base Dio instance.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api-anime-6wv4.onrender.com/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 6),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  // Add a logger interceptor for debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  return dio;
});

/// Class to handle API calls.
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Generic GET request
  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      print('API GET Error on $path: $e');
      rethrow;
    } catch (e) {
      print('Unexpected API GET Error on $path: $e');
      rethrow;
    }
  }

  // Generic POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      print('API POST Error on $path: $e');
      rethrow;
    } catch (e) {
      print('Unexpected API POST Error on $path: $e');
      rethrow;
    }
  }

  // Generic PATCH request
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      print('API PATCH Error on $path: $e');
      rethrow;
    } catch (e) {
      print('Unexpected API PATCH Error on $path: $e');
      rethrow;
    }
  }

  // Generic DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      print('API DELETE Error on $path: $e');
      rethrow;
    } catch (e) {
      print('Unexpected API DELETE Error on $path: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '/users/signup',
        data: {'username': username, 'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      String errorMessage = 'Failed to create user';
      if (e.response != null) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server did not respond in time. Please try again.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Network error or no response. Check your connection.';
      }
      print('Create user error: $errorMessage');
      return {'error': errorMessage};
    } catch (e) {
      print('An unexpected error occurred during user creation: $e');
      return {'error': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      String errorMessage = 'Error logging in';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Incorrect email or password';
      } else if (e.response != null) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out during login.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server did not respond in time during login.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error (${e.response?.statusCode}) during login.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Network error or no response during login.';
      }
      print('$errorMessage: $e');
      return {'error': errorMessage};
    }
  }
}

/// Provider for the ApiService instance.
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});