import 'package:anime_app/models/models.dart';
import 'package:anime_app/models/paginated_episodes_response_model.dart';
import 'package:anime_app/services/anime_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Providers for Anime Lists ---

/// Provider para obtener los últimos episodios agregados.
final latestEpisodesProvider = FutureProvider<List<Anime>>((ref) {
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getLatestEpisodes();
});

/// Provider para obtener los últimos animes agregados.
final latestAnimesProvider = FutureProvider<List<Anime>>((ref) {
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getLatestAnimes();
});

/// Provider para obtener la lista de animes en emisión.
final onAirAnimesProvider = FutureProvider<List<Anime>>((ref) {
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getOnAirAnimes();
});

/*
/// Provider para obtener la lista de animes finalizados.
final finishedAnimesProvider = FutureProvider<List<Anime>>((ref) {
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getFinishedAnimes();
});
*/

/// Provider para obtener la lista de próximos animes.
final comingSoonAnimesProvider = FutureProvider<List<Anime>>((ref) {
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getComingSoonAnimes();
});

// --- Providers for Anime Detail Screen ---

/// Provider para obtener los detalles de un anime específico por su slug.
final animeDetailProvider = FutureProvider.family<Anime, String>((ref, slug) {
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getAnimeDetailsBySlug(slug);
});

/// Provider para obtener la lista de episodios de un anime por su slug.
final episodeListProvider = FutureProvider.family<PaginatedEpisodesResponse, ({String slug, int page, int limit, String? sort})>((ref, params) {
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getAnimeEpisodes(params.slug, page: params.page, limit: params.limit, sort: params.sort);
});

/// Provider para mantener el estado del episodio seleccionado.
final selectedEpisodeProvider = StateProvider<int?>((ref) => null);

/// Provider para obtener los servidores de un episodio específico.
final episodeServersProvider = FutureProvider.family<List<ServerElement>, ({String slug, int episode})> ((ref, ids) {
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getEpisodeServers(ids.slug, ids.episode);
});

// --- Provider for Paginated Animes ---

class PaginatedAnimesState {
  final List<Anime> animes;
  final int page;
  final bool isLoading;
  final bool hasMore;

  PaginatedAnimesState({
    this.animes = const [],
    this.page = 1,
    this.isLoading = false,
    this.hasMore = true,
  });

  PaginatedAnimesState copyWith({
    List<Anime>? animes,
    int? page,
    bool? isLoading,
    bool? hasMore,
  }) {
    return PaginatedAnimesState(
      animes: animes ?? this.animes,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PaginatedAnimesNotifier extends StateNotifier<PaginatedAnimesState> {
  final AnimeService _animeService;

  PaginatedAnimesNotifier(this._animeService) : super(PaginatedAnimesState()) {
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final newAnimes = await _animeService.getAnimes(page: state.page, limit: 25, sort: 'desc');

    state = state.copyWith(
      animes: [...state.animes, ...newAnimes],
      page: state.page + 1,
      isLoading: false,
      hasMore: newAnimes.isNotEmpty,
    );
  }
}

final paginatedAnimesProvider = StateNotifierProvider<PaginatedAnimesNotifier, PaginatedAnimesState>((ref) {
  final animeService = ref.watch(animeServiceProvider);
  return PaginatedAnimesNotifier(animeService);
});

// --- Provider for Paginated Animes by Genre ---

class PaginatedAnimesByGenreNotifier extends StateNotifier<PaginatedAnimesState> {
  final AnimeService _animeService;
  final String genre;

  PaginatedAnimesByGenreNotifier(this._animeService, this.genre) : super(PaginatedAnimesState()) {
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final newAnimes = await _animeService.filterAnimes(
      {'genres': [genre]},
      page: state.page,
      limit: 25,
      sort: 'desc',
    );

    state = state.copyWith(
      animes: [...state.animes, ...newAnimes],
      page: state.page + 1,
      isLoading: false,
      hasMore: newAnimes.isNotEmpty,
    );
  }
}

final paginatedAnimesByGenreProvider = StateNotifierProvider.family<PaginatedAnimesByGenreNotifier, PaginatedAnimesState, String>((ref, genre) {
  final animeService = ref.watch(animeServiceProvider);
  return PaginatedAnimesByGenreNotifier(animeService, genre);
});