// ignore_for_file: avoid_print

import 'package:anime_app/models/history_model.dart';
import 'package:anime_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; // Import Dio for DioException

class HistoryService {
  final ApiService _apiService;

  HistoryService(this._apiService);

  String _extractSlug(String animeSlug) {
    if (animeSlug.startsWith('http')) {
      try {
        return Uri.parse(animeSlug).pathSegments.lastWhere((s) => s.isNotEmpty);
      } catch (e) {
        // Fallback to original slug if parsing fails
        return animeSlug;
      }
    }
    return animeSlug;
  }

  Future<List<History>> getHistory(String userId) async {
    try {
      print('HistoryService: Calling GET /history/$userId/history');
      final response = await _apiService.get('/history/$userId/history');
      print('HistoryService: getHistory response.data: ${response.data}');
      final List<dynamic>? historyData = response.data?['data']?['history'];

      if (historyData == null) {
        throw Exception('Invalid API response structure: expected a list under data.history.');
      }
      return historyData.map((json) => History.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error getting history for user $userId: $e');
      if (e.response?.statusCode == 404) {
        return []; // No history found for this user
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch history: ${e.message}');
    } catch (e) {
      print('An unexpected error occurred while fetching history: $e');
      throw Exception('An unexpected error occurred while fetching history.');
    }
  }

  Future<History?> addHistory(
    String userId,
    String animeSlug,
    num episodeNumber, {
    String? status,
  }) async {
    try {
      print(
        'HistoryService: Calling POST /history/$userId/history with animeSlug: $animeSlug, status: $status',
      );
      final response = await _apiService.post(
        '/history/$userId/history',
        data: {
          'animeSlug': _extractSlug(animeSlug),
          'lastEpisode': episodeNumber,
          'status': status ?? 'watching',
        },
      );
      print('HistoryService: addHistory response.data: ${response.data}');
      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid API response structure: expected a map.');
      }
      return History.fromJson(response.data);
    } on DioException catch (e) {
      print('Error adding history for user $userId, anime $animeSlug: $e');
      throw Exception(e.response?.data['message'] ?? 'Failed to add history: ${e.message}');
    } catch (e) {
      print('An unexpected error occurred while adding history: $e');
      throw Exception('An unexpected error occurred while adding history.');
    }
  }

  Future<History?> getAnimeHistory(String userId, String animeSlug) async {
    try {
      final finalSlug = _extractSlug(animeSlug);
      final encodedSlug = Uri.encodeComponent(finalSlug);
      print('HistoryService: Calling GET /history/$userId/history/$encodedSlug');
      final response = await _apiService.get('/history/$userId/history/$encodedSlug');
      print('HistoryService: getAnimeHistory response.data: ${response.data}');
      if (response.data == null || response.data is! Map) {
        return null; // Return null if history is not found or is null
      }
      return History.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // History for this anime not found
      }
      print('Error getting history for user $userId, anime $animeSlug: $e');
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch anime history: ${e.message}');
    } catch (e) {
      print('An unexpected error occurred while fetching anime history: $e');
      throw Exception('An unexpected error occurred while fetching anime history.');
    }
  }

  Future<History?> updateHistory(
    String userId,
    String animeSlug,
    num episodeNumber, {
    String? status,
  }) async {
    try {
      final finalSlug = _extractSlug(animeSlug);
      final encodedSlug = Uri.encodeComponent(finalSlug);
      print(
        'HistoryService: Calling PATCH /history/$userId/history/$encodedSlug with episodeNumber: $episodeNumber, status: $status',
      );
      final existingHistory = await getAnimeHistory(userId, finalSlug);
      List<num> episodesWatched = [];
      if (existingHistory != null) {
        episodesWatched = List<num>.from(existingHistory.episodesWatched);
      }

      if (!episodesWatched.contains(episodeNumber)) {
        episodesWatched.add(episodeNumber);
        episodesWatched.sort();
      }

      final response = await _apiService.patch(
        '/history/$userId/history/$encodedSlug',
        data: {
          'lastEpisode': episodeNumber,
          'episodesWatched': episodesWatched,
          'status': status ?? 'watching',
        },
      );
      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid API response structure: expected a map.');
      }
      return History.fromJson(response.data);
    } on DioException catch (e) {
      print('Error updating history for user $userId, anime $animeSlug: $e');
      throw Exception(e.response?.data['message'] ?? 'Failed to update history: ${e.message}');
    } catch (e) {
      print('An unexpected error occurred while updating history: $e');
      throw Exception('An unexpected error occurred while updating history.');
    }
  }

  Future<void> deleteHistory(String userId, String animeSlug) async {
    try {
      final finalSlug = _extractSlug(animeSlug);
      final encodedSlug = Uri.encodeComponent(finalSlug);
      print('HistoryService: Calling DELETE /api/history/$userId/history/$encodedSlug');
      await _apiService.delete('/history/$userId/history/$encodedSlug');
      print('HistoryService: Delete successful.');
    } on DioException catch (e) {
      print('Error deleting history for user $userId, anime $animeSlug: $e');
      throw Exception(e.response?.data['message'] ?? 'Failed to delete history: ${e.message}');
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
