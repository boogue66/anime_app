// ignore_for_file: avoid_print
import 'package:anime_app/models/history_model.dart';
import 'package:anime_app/services/history_service.dart';
import 'package:anime_app/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/services/anime_service.dart';
import 'package:anime_app/models/history_anime_model.dart';

// Changed generic type to List<HistoryAnime>
class HistoryNotifier extends AsyncNotifier<List<HistoryAnime>> {
  @override
  Future<List<HistoryAnime>> build() async {
    final userState = ref.watch(userProvider);
    final userId = userState.value?.id;
    if (userId == null) {
      return [];
    }
    final historyService = ref.read(historyServiceProvider);
    final animeService = ref.read(animeServiceProvider);
    final List<History> historyEntries = await historyService.getHistory(
      userId,
    );
    final List<HistoryAnime> historyAnimes = [];
    for (var entry in historyEntries) {
      try {
        final anime = await animeService.getAnimeDetailsBySlug(entry.slug);
        historyAnimes.add(
          HistoryAnime(history: entry, anime: anime),
        ); // Combine into HistoryAnime
      } catch (e) {
        print('Error fetching anime details for slug ${entry.slug}: $e');
      }
    }
    return historyAnimes;
  }

  Future<void> addOrUpdateHistory(
    String animeSlug,
    int episodeNumber, {
    String? status,
  }) async {
    state = const AsyncLoading();
    try {
      final userState = ref.read(userProvider);
      final userId = userState.value?.id;
      if (userId == null) {
        state = AsyncError('User not logged in.', StackTrace.current);
        return;
      }
      final historyService = ref.read(historyServiceProvider);
      final existingHistory = await historyService.getAnimeHistory(
        userId,
        animeSlug,
      );
      if (existingHistory != null) {
        await historyService.updateHistory(
          userId,
          animeSlug,
          episodeNumber,
          status: status,
        );
      } else {
        await historyService.addHistory(
          userId,
          animeSlug,
          episodeNumber,
          status: status,
        );
        await historyService.updateHistory(
          userId,
          animeSlug,
          episodeNumber,
          status: status,
        );
      }
      await refreshHistory();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> removeHistory(String animeSlug) async {
    state = const AsyncLoading();
    try {
      final userState = ref.read(userProvider);
      final userId = userState.value?.id;
      if (userId == null) {
        state = AsyncError('User not logged in.', StackTrace.current);
        return;
      }
      final historyService = ref.read(historyServiceProvider);
      await historyService.deleteHistory(userId, animeSlug);
      await refreshHistory();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshHistory() async {
    state = const AsyncLoading();
    await Future.delayed(Duration.zero);
    state = await AsyncValue.guard(() => build());
  }
}

// Changed generic type to List<HistoryAnime>
final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryAnime>>(() {
      return HistoryNotifier();
    });
