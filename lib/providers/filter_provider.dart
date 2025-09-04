import 'package:anime_app/models/models.dart';
import 'package:anime_app/services/anime_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Filter State
class FilterState {
  final String? type;
  final List<String> genres;
  final String? status;

  FilterState({this.type, this.genres = const [], this.status});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (type != null) map['types'] = [type];
    if (genres.isNotEmpty) map['genres'] = genres;
    if (status != null) map['statuses'] = [status];
    return map;
  }

  FilterState copyWith({
    String? type,
    List<String>? genres,
    String? status,
  }) {
    return FilterState(
      type: type ?? this.type,
      genres: genres ?? this.genres,
      status: status ?? this.status,
    );
  }
}

// 2. Filter Notifier
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState());

  void setType(String? type) {
    state = state.copyWith(type: type);
  }

  void toggleGenre(String genre) {
    final currentGenres = List<String>.from(state.genres);
    if (currentGenres.contains(genre)) {
      currentGenres.remove(genre);
    } else {
      currentGenres.add(genre);
    }
    state = state.copyWith(genres: currentGenres);
  }

  void setStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void setGenres(List<String> genres) {
    state = state.copyWith(genres: genres);
  }

  void clearFilters() {
    state = FilterState();
  }
}

// 3. Provider for the filter notifier
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

// 4. Provider to perform the search based on the filters
final filterResultProvider = FutureProvider<List<Anime>>((ref) {
  final animeService = ref.watch(animeServiceProvider);
  final filters = ref.watch(filterProvider);

  final filterMap = filters.toMap();
  if (filterMap.isEmpty) {
    return [];
  }

  return animeService.filterAnimes(filterMap);
});