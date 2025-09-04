import 'package:anime_app/models/models.dart';
import 'package:anime_app/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el servicio de animes.
final animeServiceProvider = Provider<AnimeService>((ref) {
  // Depende del provider de Dio para obtener la instancia configurada.
  return AnimeService(ref.watch(dioProvider));
});

class AnimeService {
  final Dio _dio;

  AnimeService(this._dio);

  Future<List<Anime>> _getAnimeList(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);

      if (response.data == null) {
        // ignore: avoid_print
        print('Response from $endpoint is null.');
        return [];
      }

      List<dynamic>? listData;

      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['data'] is List) {
          listData = responseMap['data'];
        } else if (responseMap['docs'] is List) {
          listData = responseMap['docs'];
        } else if (responseMap['episodes'] is List) {
          listData = responseMap['episodes'];
        } else if (responseMap['results'] is List) {
          listData = responseMap['results'];
        } else {
          // Fallback: find first list in map
          for (var value in responseMap.values) {
            if (value is List) {
              listData = value;
              break;
            }
          }
        }
      }

      if (listData != null) {
        return listData.map((item) => Anime.fromJson(item)).toList();
      } else {
        // ignore: avoid_print
        print('Could not find a list in response from $endpoint. Response: ${response.data}');
        return [];
      }
    } catch (e) {
      // Adding more detailed error logging
      String errorMessage = 'Error fetching anime list from $endpoint: $e';
      if (e is DioException) {
        errorMessage += '\nResponse: ${e.response?.data}';
      }
      // ignore: avoid_print
      print(errorMessage);
      return [];
    }
  }

  Future<List<Anime>> getLatestEpisodes() =>
      _getAnimeList('/api/animes/list/latest-episodes');

  Future<List<Anime>> getLatestAnimes() =>
      _getAnimeList('/api/animes/list/latest-animes');

  Future<List<Anime>> getOnAirAnimes() =>
      _getAnimeList('/api/animes/list/on-air');

  Future<List<Anime>> getFinishedAnimes() =>
      _getAnimeList('/api/animes/list/finished');

  Future<List<Anime>> getComingSoonAnimes() =>
      _getAnimeList('/api/animes/list/coming-soon');

  Future<List<Anime>> getAnimes({int page = 1}) {
    return _getAnimeList('/api/animes?page=$page');
  }

  Future<List<Anime>> searchAnimes(String query, {int page = 1}) {
    return _getAnimeList('/api/animes/search?query=$query&page=$page');
  }

  Future<List<Anime>> filterAnimes(Map<String, dynamic> filters) {
    return _postAnimeList('/api/animes/search/by-filter', filters);
  }

  Future<List<Anime>> _postAnimeList(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);

      if (response.data == null) {
        // ignore: avoid_print
        print('Response from $endpoint is null.');
        return [];
      }

      List<dynamic>? listData;

      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['data'] is List) {
          listData = responseMap['data'];
        } else if (responseMap['docs'] is List) {
          listData = responseMap['docs'];
        } else if (responseMap['results'] is List) {
          listData = responseMap['results'];
        } else {
          // Fallback: find first list in map
          for (var value in responseMap.values) {
            if (value is List) {
              listData = value;
              break;
            }
          }
        }
      }

      if (listData != null) {
        return listData.map((item) => Anime.fromJson(item)).toList();
      } else {
        // ignore: avoid_print
        print(
            'Could not find a list in response from $endpoint. Response: ${response.data}');
        return [];
      }
    } catch (e) {
      // Adding more detailed error logging
      String errorMessage = 'Error fetching anime list from $endpoint: $e';
      if (e is DioException) {
        errorMessage += '\nResponse: ${e.response?.data}';
      }
      // ignore: avoid_print
      print(errorMessage);
      return [];
    }
  }

  Future<Anime> getAnimeDetailsBySlug(String slug) async {
    try {
      final response = await _dio.get('/api/animes/$slug');
      return Anime.fromJson(response.data); // Assuming response is the anime object
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching anime details for $slug: $e');
      rethrow;
    }
  }

  Future<List<Episode>> getAnimeEpisodes(String slug) async {
    try {
      final response = await _dio.get('/api/animes/$slug/episodes');
      final data = response.data as List;
      return data.map((item) => Episode.fromJson(item)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching episodes for $slug: $e');
      return [];
    }
  }

  Future<List<ServerElement>> getEpisodeServers(
      String slug, int episodeNumber) async {
    try {
      final response =
          await _dio.get('/api/animes/$slug/episodes/$episodeNumber');
      final data = response.data as List;
      return data.map((item) => ServerElement.fromJson(item)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching servers for $slug episode $episodeNumber: $e');
      return [];
    }
  }
}