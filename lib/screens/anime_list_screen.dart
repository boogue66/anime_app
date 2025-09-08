import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/providers/anime_provider.dart';
import 'package:anime_app/widgets/anime_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum para representar las categorías de anime
enum AnimeCategory { latestEpisodes, latestAnimes }

// Provider para mantener el estado de la categoría seleccionada
final selectedCategoryProvider = StateProvider<AnimeCategory>(
  (ref) => AnimeCategory.latestEpisodes,
);

// Un mapa de categorías a sus nombres para mostrar en los botones
final categoryNames = {
  AnimeCategory.latestEpisodes: 'Nuevos Episodios',
  AnimeCategory.latestAnimes: 'Nuevos Animes',
};

class AnimeListScreen extends ConsumerWidget {
  const AnimeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final animeListProvider =
        () {
              switch (selectedCategory) {
                case AnimeCategory.latestEpisodes:
                  return latestEpisodesProvider;
                case AnimeCategory.latestAnimes:
                  return latestAnimesProvider;
              }
            }()
            as ProviderBase<AsyncValue<List<Anime>>>;

    final animeList = ref.watch(animeListProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AnimeCategory.values.map((category) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ElevatedButton(
                      onPressed: () => ref.read(selectedCategoryProvider.notifier).state = category,
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: selectedCategory == category
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withAlpha(180),
                        foregroundColor: selectedCategory == category
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary.withAlpha(180),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            categoryNames[category]!,
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedCategory == category
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Grid de animes
          Expanded(
            child: animeList.when(
              data: (data) {
                List<Anime> animesToDisplay = data;

                if (animesToDisplay.isEmpty) {
                  return const Center(child: Text('No se encontraron animes.'));
                }
                final mediaQuery = MediaQuery.of(context);
                final isTablet = mediaQuery.size.shortestSide >= 600;
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet
                        ? (mediaQuery.orientation == Orientation.portrait ? 4 : 7)
                        : 3, // Adjusted for tablet portrait/landscape
                    childAspectRatio: mediaQuery.orientation == Orientation.portrait ? 0.555 : 0.62,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),

                  itemCount: animesToDisplay.length,
                  itemBuilder: (context, index) {
                    final anime = animesToDisplay[index];
                    return AnimeCard(anime: anime);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
