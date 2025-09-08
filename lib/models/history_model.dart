class HistoryAnime {
  final String slug;
  final String title;
  final String poster;

  HistoryAnime({
    required this.slug,
    required this.title,
    required this.poster,
  });

  factory HistoryAnime.fromJson(Map<String, dynamic> json) {
    String posterUrl = json['poster'] ?? '';
    if (posterUrl.startsWith('/')) {
      posterUrl = 'https://www3.animeflv.net$posterUrl';
    }
    return HistoryAnime(
      slug: json['slug'] ?? '',
      title: json['title'] ?? 'No Title',
      poster: posterUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'title': title,
      'poster': poster,
    };
  }
}

class History {
  final String id;
  final String userId;
  final String status;
  final List<int> episodesWatched;
  final int lastEpisode;
  final String animeId;
  final HistoryAnime? anime;

  History({
    required this.id,
    required this.userId,
    required this.status,
    required this.episodesWatched,
    required this.lastEpisode,
    required this.animeId,
    this.anime,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? 'watching',
      episodesWatched: List<int>.from(json['episodesWatched'] ?? []),
      lastEpisode: (json['lastEpisode'] as num?)?.toInt() ?? 0,
      animeId: json['animeId'] ?? '',
      anime: json['anime'] != null ? HistoryAnime.fromJson(json['anime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'status': status,
      'episodesWatched': episodesWatched,
      'lastEpisode': lastEpisode,
      'animeId': animeId,
      'anime': anime?.toJson(),
    };
  }
}