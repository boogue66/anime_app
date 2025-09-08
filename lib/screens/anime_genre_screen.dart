import 'package:anime_app/providers/anime_provider.dart';
import 'package:anime_app/widgets/anime_card.dart';
import 'package:anime_app/widgets/anime_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/widgets/custom_bottom_navigation_bar.dart';

class AnimeGenreScreen extends ConsumerStatefulWidget {
  final String genre;

  const AnimeGenreScreen({super.key, required this.genre});

  @override
  ConsumerState<AnimeGenreScreen> createState() => _AnimeGenreScreenState();
}

class _AnimeGenreScreenState extends ConsumerState<AnimeGenreScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(paginatedAnimesByGenreProvider(widget.genre).notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final animesState = ref.watch(paginatedAnimesByGenreProvider(widget.genre));
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(title: Text(widget.genre)),
      body: animesState.animes.isEmpty && animesState.isLoading
          ? _buildLoadingGrid()
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedAnimesByGenreProvider(widget.genre));
              },
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet
                      ? (mediaQuery.orientation == Orientation.portrait ? 4 : 7)
                      : (mediaQuery.orientation == Orientation.portrait
                            ? 3
                            : 4), // Adjusted for tablet portrait/landscape
                  childAspectRatio: mediaQuery.orientation == Orientation.portrait ? 0.555 : 0.62,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: animesState.animes.length + (animesState.isLoading ? 4 : 0),
                itemBuilder: (context, index) {
                  if (index < animesState.animes.length) {
                    final anime = animesState.animes[index];
                    return AnimeCard(anime: anime);
                  } else {
                    return const AnimeCardSkeleton();
                  }
                },
              ),
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 0, // Placeholder, as this screen is not part of main navigation
        onItemTapped: (index) {
          // Placeholder: In a real app, this would navigate to different main sections.
          // ignore: avoid_print
          print('Tapped on index: $index');
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet
            ? (mediaQuery.orientation == Orientation.portrait ? 4 : 7)
            : (mediaQuery.orientation == Orientation.portrait
                  ? 3
                  : 4), // Adjusted for tablet portrait/landscape
        childAspectRatio: mediaQuery.orientation == Orientation.portrait ? 0.555 : 0.62,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      itemCount: 4, // Show 4 skeleton cards while loading initially
      itemBuilder: (context, index) {
        return const AnimeCardSkeleton();
      },
    );
  }
}
