// ignore_for_file: avoid_print

import 'package:anime_app/models/models.dart';
import 'package:anime_app/models/paginated_episodes_response_model.dart';
import 'package:anime_app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el servicio de animes.
final animeServiceProvider = Provider<AnimeService>((ref) {
  return AnimeService(ref.watch(dioProvider));
});

class AnimeService {
  final Dio _dio;
  AnimeService(this._dio);
  Future<List<Anime>> _getAnimeList(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      if (response.data == null) {
        print('Response from $endpoint is null.');
        return [];
      }
      // As per swagger.yaml, paginated responses use 'docs' key
      final listData = response.data['docs'] as List<dynamic>?;

      if (listData != null) {
        return listData.map((item) => Anime.fromJson(item)).toList();
      } else {
        print('Could not find \'docs\' key in response from $endpoint. Response: ${response.data}');
        return [];
      }
    } catch (e) {
      // Adding more detailed error logging
      String errorMessage = 'Error fetching anime list from $endpoint: $e';
      if (e is DioException) {
        errorMessage += '\nResponse: ${e.response?.data}';
      }
      print(errorMessage);
      return [];
    }
  }

  Future<List<Anime>> getLatestEpisodes() => _getAnimeList('/api/animes/list/latest-episodes?limit=30');

  Future<List<Anime>> getLatestAnimes() => _getAnimeList('/api/animes/list/latest-animes?limit=30');

  Future<List<Anime>> getOnAirAnimes() => _getAnimeList('/api/animes/list/on-air');

  Future<List<Anime>> getComingSoonAnimes() => _getAnimeList('/api/animes/list/coming-soon');

  Future<List<Anime>> getAnimes({int page = 1, int limit = 25, String sort = 'desc'}) {
    return _getAnimeList('/api/animes?page=$page&limit=$limit&sort=$sort');
  }

  Future<List<Anime>> searchAnimes(
    String query, {
    int page = 1,
    int limit = 25,
    String sort = 'desc',
  }) {
    return _getAnimeList('/api/animes/search?query=$query&page=$page&limit=$limit&sort=$sort');
  }

  Future<List<Anime>> filterAnimes(
    Map<String, dynamic> filters, {
    int page = 1,
    int limit = 25,
    String sort = 'desc',
  }) {
    final queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
    };
    // Remove page, limit, sort from filters if they were mistakenly added to body
    final bodyFilters = Map<String, dynamic>.from(filters);
    bodyFilters.remove('page');
    bodyFilters.remove('limit');
    bodyFilters.remove('sort');

    final uri = Uri.parse('/api/animes/search/by-filter').replace(queryParameters: queryParameters);
    return _postAnimeList(uri.toString(), bodyFilters);
  }

  Future<List<Anime>> _postAnimeList(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      if (response.data == null) {
        print('Response from $endpoint is null.');
        return [];
      }

      // As per swagger.yaml, paginated responses use 'docs' key
      final listData = response.data['docs'] as List<dynamic>?;

      if (listData != null) {
        return listData.map((item) => Anime.fromJson(item)).toList();
      } else {
        print('Could not find \'docs\' key in response from $endpoint. Response: ${response.data}');
        return [];
      }
    } catch (e) {
      // Adding more detailed error logging
      String errorMessage = 'Error fetching anime list from $endpoint: $e';
      if (e is DioException) {
        errorMessage += '\nResponse: ${e.response?.data}';
      }
      print(errorMessage);
      return [];
    }
  }

  Future<Anime> getAnimeDetailsBySlug(
    String slug, {
    int page = 1,
    int limit = 25,
    String? sort,
  }) async {
    try {
      var endpoint = '/api/animes/$slug?page=$page&limit=$limit';
      if (sort != null) {
        endpoint += '&sort=$sort';
      }
      final response = await _dio.get(endpoint);
      return Anime.fromJson(response.data);
    } catch (e) {
      print('Error fetching anime details for $slug: $e');
      rethrow;
    }
  }

  Future<PaginatedEpisodesResponse> getAnimeEpisodes(
    String slug, {
    int page = 1,
    int limit = 25,
    String? sort,
  }) async {
    try {
      var endpoint = '/api/animes/$slug/episodes?page=$page&limit=$limit';
      if (sort != null) {
        endpoint += '&sort=$sort';
      }
      final response = await _dio.get(endpoint);
      return PaginatedEpisodesResponse.fromJson(response.data);
    } catch (e) {
      print('Error fetching episodes for $slug: $e');
      rethrow;
    }
  }

  Future<List<ServerElement>> getEpisodeServers(String slug, int episodeNumber) async {
    try {
      final response = await _dio.get('/api/animes/$slug/episodes/$episodeNumber');
      final data = response.data as List;
      return data.map((item) => ServerElement.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching servers for $slug episode $episodeNumber: $e');
      return [];
    }
  }

  Future<Anime> createAnime(Anime anime) async {
    try {
      final response = await _dio.post('/api/animes/new', data: anime.toJson());
      return Anime.fromJson(response.data);
    } catch (e) {
      print('Error creating anime: $e');
      rethrow;
    }
  }

  Future<Anime> updateAnime(String id, Anime anime) async {
    try {
      final response = await _dio.put('/api/animes/$id', data: anime.toJson());
      return Anime.fromJson(response.data);
    } catch (e) {
      print('Error updating anime $id: $e');
      rethrow;
    }
  }

  Future<void> deleteAnime(String id) async {
    try {
      await _dio.delete('/api/animes/$id');
    } catch (e) {
      print('Error deleting anime $id: $e');
      rethrow;
    }
  }
}
