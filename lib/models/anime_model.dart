import 'package:anime_app/models/episode_model.dart';

class Anime {
  final String id;
  final String? url;
  final List<String> alternativeTitles;
  final String? description;
  final List<Episode> episodes;
  final List<String> genres;
  final String poster;
  final String status;
  final String title;
  final String? type;
  final int? year;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? lastEpisode;
  final String slug;

  Anime({
    required this.id,
    this.url,
    required this.alternativeTitles,
    this.description,
    required this.episodes,
    required this.genres,
    required this.poster,
    required this.status,
    required this.title,
    this.type,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.lastEpisode,
    required this.slug,
  });

  /// Factory para construir desde JSON
  factory Anime.fromJson(Map<String, dynamic> json) {
    String posterUrl = json['poster'] ?? '';
    if (posterUrl.startsWith('/')) {
      posterUrl = 'https://www3.animeflv.net$posterUrl';
    }

    return Anime(
      id: json['_id'] ?? '',
      url: json['url'],
      alternativeTitles: json['alternativeTitles'] == null
          ? []
          : List<String>.from(json['alternativeTitles']),
      description: json['description'],
      episodes: json['episodes'] == null
          ? []
          : (json['episodes'] as List<dynamic>)
                .map((e) => Episode.fromJson(e))
                .toList(),
      genres: json['genres'] == null ? [] : List<String>.from(json['genres']),
      poster: posterUrl,
      status: json['status'] ?? 'N/A',
      title: json['title'] ?? 'No Title',
      type: json['type'],
      year: (json['year'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt']),
      lastEpisode: (json['lastEpisode'] as num?)?.toInt(),
      slug: json['slug'] ?? '',
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
    '_id': id,
    'url': url,
    'alternativeTitles': alternativeTitles,
    'description': description,
    'episodes': episodes.map((e) => e.toJson()).toList(),
    'genres': genres,
    'poster': poster,
    'status': status,
    'title': title,
    'type': type,
    'year': year,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'lastEpisode': lastEpisode,
    'slug': slug,
  };
}
