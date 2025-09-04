// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que crea la instancia base de Dio.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api-anime-6wv4.onrender.com',
      // Aquí puedes añadir headers por defecto, como la clave de la API
      headers: {
        // 'X-MAL-CLIENT-ID': 'TU_CLIENT_ID',
      },
      connectTimeout: const Duration(seconds: 10), // Increased from 5
      receiveTimeout: const Duration(seconds: 6), // Increased from 3
    ),
  );

  // Añade un interceptor para logging solo en modo debug
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  return dio;
});

/// Clase para manejar las llamadas a la API.
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Generic GET request
  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      print('API GET Error on $path: $e');
      rethrow; // Re-throw to be caught by specific service methods
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

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _dio.get('/api/users');
      // Assuming the API returns a structure like { "data": { "users": [...] } }
      return List<Map<String, dynamic>>.from(response.data['data']['users']);
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createUser(String username, String email) async {
    try {
      final response = await _dio.post(
        '/api/users',
        data: {'username': username, 'email': email},
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
      print('Create user error: $errorMessage'); // Added print for debugging
      return {'error': errorMessage};
    } catch (e) {
      print('An unexpected error occurred during user creation: $e'); // More specific print
      return {'error': 'An unexpected error occurred'};
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      await _dio.get('/api/users/check/$email');
      return true; // Exists
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false; // Doesn't exist
      }
      String errorMessage = 'Error checking email';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out while checking email.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server did not respond in time while checking email.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error (${e.response?.statusCode}) while checking email.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Network error or no response while checking email.';
      }
      print('$errorMessage: $e'); // More specific print
      return false;
    } catch (e) {
      print('An unexpected error occurred during email check: $e'); // More specific print
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email) async {
    try {
      final response = await _dio.get('/api/users/check/$email');
      return response.data['data']['user'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      String errorMessage = 'Error logging in';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out during login.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server did not respond in time during login.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error (${e.response?.statusCode}) during login.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Network error or no response during login.';
      }
      print('$errorMessage: $e'); // More specific print
      return null;
    }
  }
}

/// Provider para la instancia de ApiService.
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});
