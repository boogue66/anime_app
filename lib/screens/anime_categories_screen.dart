import 'package:anime_app/providers/filter_provider.dart';
import 'package:anime_app/widgets/anime_card.dart';
import 'package:anime_app/widgets/custom_searchable_dropdown.dart';
import 'package:anime_app/widgets/multi_select_chip_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimeCategoriesScreen extends ConsumerWidget {
  AnimeCategoriesScreen({super.key});

  // Hardcoded values for dropdowns
  final List<String> _types = ['Anime', 'Pelicula', 'OVA', 'Especial'];
  final List<String> _genres = [
    'Acción',
    'Artes Marciales',
    'Aventuras',
    'Carreras',
    'Ciencia Ficción',
    'Comedia',
    'Demencia',
    'Demonios',
    'Deportes',
    'Drama',
    'Ecchi',
    'Escolares',
    'Espacial',
    'Fantasía',
    'Harem',
    'Historico',
    'Infantil',
    'Josei',
    'Juegos',
    'Magia',
    'Mecha',
    'Militar',
    'Misterio',
    'Música',
    'Parodia',
    'Policía',
    'Psicológico',
    'Recuentos de la vida',
    'Romance',
    'Samurai',
    'Seinen',
    'Shoujo',
    'Shounen',
    'Sobrenatural',
    'Superpoderes',
    'Suspenso',
    'Terror',
    'Vampiros',
    'Yaoi',
    'Yuri',
  ];
  final List<String> _statuses = ['En emision', 'Finalizado'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomSearchableDropdown(
                    hintText: 'Tipo',
                    items: _types,
                    selectedItem: filters.type,
                    onChanged: (value) {
                      ref.read(filterProvider.notifier).setType(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MultiSelectChipDropdown(
                    hintText: 'Genero',
                    items: _genres,
                    selectedItems: filters.genres,
                    onChanged: (values) {
                      ref.read(filterProvider.notifier).setGenres(values);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomSearchableDropdown(
                    hintText: 'Status',
                    items: _statuses,
                    selectedItem: filters.status,
                    onChanged: (value) {
                      ref.read(filterProvider.notifier).setStatus(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Expanded(child: FilterResults()),
          ],
        ),
      ),
    );
  }
}

class FilterResults extends ConsumerWidget {
  const FilterResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterResult = ref.watch(filterResultProvider);

    return filterResult.when(
      data: (animes) {
        if (animes.isEmpty) {
          return const Center(child: Text('No results found.'));
        }
        final mediaQuery = MediaQuery.of(context);
        final isTablet = mediaQuery.size.shortestSide >= 600;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet
                ? (mediaQuery.orientation == Orientation.portrait ? 4 : 7)
                : 3,
            childAspectRatio: mediaQuery.orientation == Orientation.portrait
                ? 0.555
                : 0.62,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          padding: const EdgeInsets.all(5),
          itemCount: animes.length,
          itemBuilder: (context, index) {
            final anime = animes[index];
            return AnimeCard(anime: anime);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text('An error occurred.')),
    );
  }
}
