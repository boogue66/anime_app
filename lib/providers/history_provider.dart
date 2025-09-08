// ignore_for_file: avoid_print
import 'package:anime_app/models/history_model.dart';
import 'package:anime_app/services/history_service.dart';
import 'package:anime_app/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryNotifier extends AsyncNotifier<List<History>> {
  @override
  Future<List<History>> build() async {
    final userState = ref.watch(userProvider);
    final userId = userState.value?.id;
    if (userId == null) {
      print('HistoryNotifier: User not logged in, returning empty history.');
      return [];
    }
    final historyService = ref.read(historyServiceProvider);
    print('HistoryNotifier: Fetching history for user $userId');
    final List<History> historyEntries = await historyService.getHistory(
      userId,
    );
    print('HistoryNotifier: Fetched ${historyEntries.length} history entries.');
    return historyEntries;
  }

  Future<void> addOrUpdateHistory(
    String animeSlug,
    num episodeNumber, {
    String? status,
  }) async {
    print('HistoryNotifier: addOrUpdateHistory called for anime: $animeSlug, episode: $episodeNumber, status: $status');
    state = const AsyncLoading();
    try {
      final userState = ref.read(userProvider);
      final userId = userState.value?.id;
      if (userId == null) {
        state = AsyncError('User not logged in.', StackTrace.current);
        return;
      }
      final historyService = ref.read(historyServiceProvider); // Assuming historyServiceProvider provides HistoryService
      final existingHistory = await historyService.getAnimeHistory(
        userId,
        animeSlug,
      );
      if (existingHistory != null) {
        print('HistoryNotifier: Updating existing history.');
        await historyService.updateHistory(
          userId,
          animeSlug,
          episodeNumber,
          status: status,
        );
      } else {
        print('HistoryNotifier: Adding new history.');
        await historyService.addHistory(
          userId,
          animeSlug,
          episodeNumber,
          status: status,
        );
      }
      print('HistoryNotifier: Calling refreshHistory after add/update.');
      await refreshHistory();
      print('HistoryNotifier: refreshHistory completed.');
    } catch (e, st) {
      print('HistoryNotifier: Error in addOrUpdateHistory: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> removeHistory(String animeSlug) async {
    print('HistoryNotifier: removeHistory called for anime: $animeSlug');
    try {
      final userState = ref.read(userProvider);
      final userId = userState.value?.id;
      if (userId == null) {
        state = AsyncError('User not logged in.', StackTrace.current);
        return;
      }

      final historyService = ref.read(historyServiceProvider);
      await historyService.deleteHistory(userId, animeSlug);
      print('HistoryNotifier: Successfully deleted $animeSlug from backend.');
      print('HistoryNotifier: Calling refreshHistory after delete.');
      await refreshHistory();
      print('HistoryNotifier: refreshHistory completed.');
    } catch (e, st) {
      print('HistoryNotifier: Error in removeHistory: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshHistory() async {
    print('HistoryNotifier: refreshHistory called.');
    state = const AsyncLoading();
    await Future.delayed(Duration.zero);
    state = await AsyncValue.guard(() => build());
    print('HistoryNotifier: refreshHistory completed, new state: ${state.value?.length ?? 0} items.');
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<History>>(() {
      return HistoryNotifier();
    });
