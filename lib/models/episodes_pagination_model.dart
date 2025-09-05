class EpisodesPagination {
  final int totalEpisodes;
  final int totalPages;
  final int currentPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  EpisodesPagination({
    required this.totalEpisodes,
    required this.totalPages,
    required this.currentPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory EpisodesPagination.fromJson(Map<String, dynamic> json) {
    return EpisodesPagination(
      totalEpisodes: json['totalEpisodes'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}
