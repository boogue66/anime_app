import 'dart:async';

import 'package:anime_app/models/models.dart';
import 'package:anime_app/services/anime_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Debounced Search Query Notifier
class DebouncedSearchNotifier extends StateNotifier<String> {
  Timer? _debounce;

  DebouncedSearchNotifier() : super('');

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      state = query;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// 2. Provider for the debounced search notifier
final debouncedSearchProvider =
    StateNotifierProvider<DebouncedSearchNotifier, String>((ref) {
  return DebouncedSearchNotifier();
});

// 3. Paginated Search State
class PaginatedSearchState {
  final List<Anime> animes;
  final int page;
  final bool isLoading;
  final String query;

  PaginatedSearchState({
    this.animes = const [],
    this.page = 1,
    this.isLoading = false,
    this.query = '',
  });

  PaginatedSearchState copyWith({
    List<Anime>? animes,
    int? page,
    bool? isLoading,
    String? query,
  }) {
    return PaginatedSearchState(
      animes: animes ?? this.animes,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
    );
  }
}

// 4. Paginated Search Notifier
class PaginatedSearchNotifier extends StateNotifier<PaginatedSearchState> {
  final AnimeService _animeService;

  PaginatedSearchNotifier(this._animeService, Ref ref)
      : super(PaginatedSearchState()) {
    ref.listen<String>(debouncedSearchProvider, (previous, next) {
      if (next.length >= 3) {
        state = PaginatedSearchState(query: next, isLoading: true);
        _fetchFirstPage();
      } else {
        state = PaginatedSearchState();
      }
    });
  }

  Future<void> _fetchFirstPage() async {
    final animes = await _animeService.searchAnimes(state.query, page: 1);
    if (mounted) {
      state = state.copyWith(animes: animes, page: 2, isLoading: false);
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !mounted) return;

    state = state.copyWith(isLoading: true);

    final newAnimes = await _animeService.searchAnimes(state.query, page: state.page);

    if (mounted) {
      state = state.copyWith(
        animes: [...state.animes, ...newAnimes],
        page: state.page + 1,
        isLoading: false,
      );
    }
  }
}

// 5. Provider for paginated search results
final paginatedSearchResultProvider =
    StateNotifierProvider<PaginatedSearchNotifier, PaginatedSearchState>((ref) {
  final animeService = ref.watch(animeServiceProvider);
  return PaginatedSearchNotifier(animeService, ref);
});