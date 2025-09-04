class History {
  final String id;
  final String userId;
  final String status;
  final List<dynamic> episodesWatched;
  final int lastEpisode;
  final DateTime updatedAt;
  final int v;
  final String slug;

  History({
    required this.id,
    required this.userId,
    required this.status,
    required this.episodesWatched,
    required this.lastEpisode,
    required this.updatedAt,
    required this.v,
    required this.slug,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? 'watching',
      episodesWatched: json['episodesWatched'] ?? [],
      lastEpisode: json['lastEpisode'] ?? 0,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      v: json['__v'] ?? 0,
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'status': status,
      'episodesWatched': episodesWatched,
      'lastEpisode': lastEpisode,
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'slug': slug,
    };
  }
}
