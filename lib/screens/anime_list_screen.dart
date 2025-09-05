import 'package:anime_app/providers/anime_provider.dart';
import 'package:anime_app/widgets/anime_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum para representar las categorías de anime
enum AnimeCategory { latestEpisodes, latestAnimes }

// Provider para mantener el estado de la categoría seleccionada
final selectedCategoryProvider = StateProvider<AnimeCategory>(
  (ref) => AnimeCategory.latestAnimes,
);

// Un mapa de categorías a sus nombres para mostrar en los botones
final categoryNames = {
  AnimeCategory.latestAnimes: 'News Ani',
  AnimeCategory.latestEpisodes: 'News Eps',
};

class AnimeListScreen extends ConsumerWidget {
  const AnimeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Elige el provider correcto basado en la categoría seleccionada
    final animeListProvider = () {
      switch (selectedCategory) {
        case AnimeCategory.latestEpisodes:
          return latestEpisodesProvider;
        case AnimeCategory.latestAnimes:
          return latestAnimesProvider;
      }
    }();

    final animeList = ref.watch(animeListProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: AnimeCategory.values.map((category) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                    child: ElevatedButton(
                      onPressed: () =>
                          ref.read(selectedCategoryProvider.notifier).state =
                              category,
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: selectedCategory == category
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        foregroundColor: selectedCategory == category
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                      child: Text(
                        categoryNames[category]!,
                        style: TextStyle(
                          color: selectedCategory == category
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.surface,
                        ),
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
              data: (animes) {
                if (animes.isEmpty) {
                  return const Center(child: Text('No se encontraron animes.'));
                }
                final mediaQuery = MediaQuery.of(context);
                final isTablet = mediaQuery.size.shortestSide >= 600;
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet
                        ? (mediaQuery.orientation == Orientation.portrait
                              ? 4
                              : 7)
                        : 3, // Adjusted for tablet portrait/landscape
                    childAspectRatio:
                        mediaQuery.orientation == Orientation.portrait
                        ? 0.555
                        : 0.62,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),

                  itemCount: animes.length,
                  itemBuilder: (context, index) {
                    final anime = animes[index];
                    return AnimeCard(anime: anime);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
