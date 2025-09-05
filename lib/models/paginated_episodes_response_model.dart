import 'package:anime_app/models/episode_model.dart';
import 'package:anime_app/models/episodes_pagination_model.dart';

class PaginatedEpisodesResponse {
  final List<Episode> episodes;
  final EpisodesPagination pagination;

  PaginatedEpisodesResponse({
    required this.episodes,
    required this.pagination,
  });

  factory PaginatedEpisodesResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedEpisodesResponse(
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e))
              .toList() ??
          [],
      pagination: EpisodesPagination.fromJson(json['episodesPagination'] ?? {}),
    );
  }
}
