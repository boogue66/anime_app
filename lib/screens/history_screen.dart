import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/providers/history_provider.dart';
import 'package:anime_app/providers/user_provider.dart';
import 'package:anime_app/widgets/history_card.dart';

final selectedHistoryStatusProvider = StateProvider<String>(
  (ref) => 'watching',
); // Default to 'watching'

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(selectedHistoryStatusProvider);
    final historyAsyncValue = ref.watch(historyProvider);
    final userAsyncValue = ref.watch(userProvider);

    if (userAsyncValue.value == null) {
      return const Center(
        child: Text(
          'Please log in to view your history.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(selectedHistoryStatusProvider.notifier).state =
                          'watching';
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedStatus == 'watching'
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                    child: const Text('Viendo'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(selectedHistoryStatusProvider.notifier).state =
                          'completed';
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedStatus == 'completed'
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                    child: const Text('Terminados'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: historyAsyncValue.when(
              data: (historyAnimeList) {
                if (historyAnimeList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No history found. Start watching some animes!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                final filteredAnimes = historyAnimeList
                    .where((item) => item.history.status == selectedStatus)
                    .toList();

                if (filteredAnimes.isEmpty) {
                  return Center(
                    child: Text(
                      'No $selectedStatus animes found.',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredAnimes.length,
                  itemBuilder: (context, index) {
                    final item = filteredAnimes[index];
                    return HistoryCard(item: item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading history: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
