// ignore_for_file: avoid_print

import 'package:anime_app/models/history_model.dart';
import 'package:anime_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; // Import Dio for DioException

class HistoryService {
  final ApiService _apiService;

  HistoryService(this._apiService);

  Future<List<History>> getHistory(String userId) async {
    try {
      final response = await _apiService.get('/api/history/$userId/history');
      // Add null/empty checks for response.data and its keys
      if (response.data == null ||
          !response.data.containsKey('data') ||
          !response.data['data'].containsKey('history')) {
        throw Exception(
          'Invalid API response structure: missing data or history key.',
        );
      }
      return (response.data['data']['history'] as List)
          .map((json) => History.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print('Error getting history for user $userId: $e');
      if (e.response?.statusCode == 404) {
        return []; // No history found for this user
      }
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch history: ${e.message}',
      );
    } catch (e) {
      print('An unexpected error occurred while fetching history: $e');
      throw Exception('An unexpected error occurred while fetching history.');
    }
  }

  Future<History?> addHistory(
    String userId,
    String animeSlug,
    int episodeNumber, {
    String? status,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/history/$userId/history',
        data: {
          'animeSlug': animeSlug,
          'status': status ?? 'watching',
        },
      );
      if (response.data == null ||
          !response.data.containsKey('data') ||
          !response.data['data'].containsKey('history')) {
        throw Exception(
          'Invalid API response structure: missing data or history key.',
        );
      }
      return History.fromJson(response.data['data']['history']);
    } on DioException catch (e) {
      print('Error adding history for user $userId, anime $animeSlug: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to add history: ${e.message}',
      );
    } catch (e) {
      print('An unexpected error occurred while adding history: $e');
      throw Exception('An unexpected error occurred while adding history.');
    }
  }

  Future<History?> getAnimeHistory(String userId, String animeSlug) async {
    try {
      final response = await _apiService.get(
        '/api/history/$userId/history/$animeSlug',
      );
      if (response.data == null ||
          !response.data.containsKey('data') ||
          !response.data['data'].containsKey('history')) {
        throw Exception(
          'Invalid API response structure: missing data or history key.',
        );
      }
      return History.fromJson(response.data['data']['history']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // History for this anime not found
      }
      print('Error getting history for user $userId, anime $animeSlug: $e');
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch anime history: ${e.message}',
      );
    } catch (e) {
      print('An unexpected error occurred while fetching anime history: $e');
      throw Exception(
        'An unexpected error occurred while fetching anime history.',
      );
    }
  }

  Future<History?> updateHistory(
    String userId,
    String animeSlug,
    int episodeNumber, {
    String? status,
  }) async {
    try {
      // Fetch existing history to get episodesWatched
      final existingHistory = await getAnimeHistory(userId, animeSlug);
      List<int> episodesWatched = [];
      if (existingHistory != null) {
        episodesWatched = List<int>.from(
          existingHistory.episodesWatched.map((e) => e as int),
        );
      }

      // Add current episode if not already in the list
      if (!episodesWatched.contains(episodeNumber)) {
        episodesWatched.add(episodeNumber);
        episodesWatched.sort(); // Keep it sorted
      }

      final response = await _apiService.patch(
        '/api/history/$userId/history/$animeSlug',
        data: {
          'lastEpisode': episodeNumber,
          'episodesWatched': episodesWatched,
          'status': status ?? 'watching',
        },
      );
      if (response.data == null ||
          !response.data.containsKey('data') ||
          !response.data['data'].containsKey('history')) {
        throw Exception(
          'Invalid API response structure: missing data or history key.',
        );
      }
      return History.fromJson(response.data['data']['history']);
    } on DioException catch (e) {
      print('Error updating history for user $userId, anime $animeSlug: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update history: ${e.message}',
      );
    } catch (e) {
      print('An unexpected error occurred while updating history: $e');
      throw Exception('An unexpected error occurred while updating history.');
    }
  }

  Future<void> deleteHistory(String userId, String animeSlug) async {
    try {
      await _apiService.delete('/api/history/$userId/history/$animeSlug');
    } on DioException catch (e) {
      print('Error deleting history for user $userId, anime $animeSlug: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete history: ${e.message}',
      );
    } catch (e) {
      print('An unexpected error occurred while deleting history: $e');
      throw Exception('An unexpected error occurred while deleting history.');
    }
  }
}

final historyServiceProvider = Provider<HistoryService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return HistoryService(apiService);
});
