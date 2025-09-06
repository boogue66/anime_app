import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/providers/anime_provider.dart';
import 'package:anime_app/screens/episode_player_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:anime_app/providers/history_provider.dart';

class AnimeDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  const AnimeDetailScreen({super.key, required this.slug, required String id});

  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen> {
  bool _isAscendingOrder = true;

  @override
  Widget build(BuildContext context) {
    final animeDetail = ref.watch(animeDetailProvider(widget.slug));
    final isLandscape = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: animeDetail.when(
        data: (anime) {
          return isLandscape
              ? _buildLandscapeLayout(context, anime)
              : _buildPortraitLayout(context, anime);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, Anime anime) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 5,
              expandedHeight: 390.0,
              pinned: true,
              floating: false,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  anime.title,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: anime.poster,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.8),
                          end: Alignment(0.0, 0.0),
                          colors: <Color>[Color(0xC3000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _AnimeDetails(anime: anime)),
            SliverToBoxAdapter(
              child: _EpisodeListHeader(
                isAscending: _isAscendingOrder,
                onSortPressed: () {
                  setState(() {
                    _isAscendingOrder = !_isAscendingOrder;
                  });
                },
              ),
            ),
            _EpisodeList(
              slug: widget.slug,
              isAscending: _isAscendingOrder,
              isSliver: true,
              totalEpisodes: anime.episodesPagination?.totalEpisodes ?? 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, Anime anime) {
    return Scaffold(
      appBar: AppBar(
        title: Text(anime.title),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(10),
      ),
      body: SafeArea(
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedNetworkImage(
                          imageUrl: anime.poster,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _AnimeDetails(anime: anime),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    _EpisodeListHeader(
                      isAscending: _isAscendingOrder,
                      onSortPressed: () {
                        setState(() {
                          _isAscendingOrder = !_isAscendingOrder;
                        });
                      },
                    ),
                    Expanded(
                      child: _EpisodeList(
                        slug: widget.slug,
                        isAscending: _isAscendingOrder,
                        isSliver: false,
                        totalEpisodes:
                            anime.episodesPagination?.totalEpisodes ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimeDetails extends StatelessWidget {
  final Anime anime;

  const _AnimeDetails({required this.anime});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sinopsis',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            anime.description ?? 'No description available.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 16),
          Text(
            'Géneros',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: anime.genres
                .map(
                  (genre) => InputChip(
                    label: Text(genre),
                    elevation: 0,
                    selected: true,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _EpisodeListHeader extends StatelessWidget {
  final bool isAscending;
  final VoidCallback onSortPressed;

  const _EpisodeListHeader({
    required this.isAscending,
    required this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).colorScheme.primary.withAlpha(220),
          boxShadow: [BoxShadow(blurRadius: 4.0, offset: const Offset(0, 2))],
        ),

        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episodios',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(
                isAscending
                    ? Icons.keyboard_double_arrow_up
                    : Icons.keyboard_double_arrow_down,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: 'Ordenar episodios',
              onPressed: onSortPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeList extends ConsumerStatefulWidget {
  final String slug;
  final bool isAscending;
  final bool isSliver;
  final int totalEpisodes;

  const _EpisodeList({
    required this.slug,
    required this.isAscending,
    this.isSliver = false,
    required this.totalEpisodes,
  });

  @override
  ConsumerState<_EpisodeList> createState() => _EpisodeListState();
}

class _EpisodeListState extends ConsumerState<_EpisodeList> {
  final Map<int, List<Episode>> _episodesByGroup = {};
  final Map<int, bool> _isLoadingGroup = {};

  @override
  void initState() {
    super.initState();
    // Load the first group of episodes immediately if there are more than 50 episodes
    if (widget.totalEpisodes > 25) {
      _fetchEpisodesForGroup(0, 1);
    } else {
      // If 25 or fewer episodes, fetch all of them immediately
      _fetchEpisodesForGroup(0, 1, limit: widget.totalEpisodes);
    }
  }

  @override
  void didUpdateWidget(covariant _EpisodeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAscending != oldWidget.isAscending) {
      // Clear cached episodes and loading states to force re-fetch with new sort order
      _episodesByGroup.clear();
      _isLoadingGroup.clear();
      // Re-fetch the first group immediately if applicable
      if (widget.totalEpisodes > 50) {
        _fetchEpisodesForGroup(0, 1);
      } else {
        _fetchEpisodesForGroup(0, 1, limit: widget.totalEpisodes);
      }
      setState(() {}); // Trigger a rebuild
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalEpisodes <= 50) {
      return _buildSimpleEpisodeList(context);
    } else {
      final totalGroups = (widget.totalEpisodes / 25).ceil();
      if (widget.isSliver) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildGroupTile(context, index, totalGroups),
            childCount: totalGroups,
          ),
        );
      } else {
        return Expanded(
          // Wrap in Expanded
          child: ListView.builder(
            primary: false, // Important for nested scroll views
            shrinkWrap: true, // Important for nested scroll views
            itemCount: totalGroups,
            itemBuilder: (context, index) {
              final actualIndex = widget.isAscending
                  ? index
                  : totalGroups - 1 - index;
              return _buildGroupTile(context, actualIndex, totalGroups);
            },
          ),
        );
      }
    }
  }

  Widget _buildSimpleEpisodeList(BuildContext context) {
    if (widget.totalEpisodes <= 25) {
      return _buildSimpleEpisodeList(context);
    } else if (_episodesByGroup[0] == null || _episodesByGroup[0]!.isEmpty) {
      return widget.isSliver
          ? const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      final episodes = _episodesByGroup[0]!;
      if (widget.isSliver) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildEpisodeTile(context, episodes[index]),
            childCount: episodes.length,
          ),
        );
      } else {
        return ListView.builder(
          itemCount: episodes.length,
          itemBuilder: (context, index) =>
              _buildEpisodeTile(context, episodes[index]),
        );
      }
    }
  }

  Widget _buildGroupTile(
    BuildContext context,
    int actualIndex,
    int totalGroups,
  ) {
    final groupStart = actualIndex * 25 + 1;
    final groupEnd = groupStart + 24;
    final groupTitle = 'Episodios $groupStart - $groupEnd';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).colorScheme.primary.withAlpha(50),
        ),
        child: ExpansionTile(
          // This is the line that was causing the error
          key: ValueKey('${actualIndex}_${widget.isAscending}'),
          expansionAnimationStyle: AnimationStyle(
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 500),
            reverseCurve: Curves.bounceOut,
            reverseDuration: const Duration(milliseconds: 500),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          tilePadding: const EdgeInsets.all(2),
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(10),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Padding(
            // This is the line that was causing the error
            padding: const EdgeInsets.all(8.0),
            child: Text(
              groupTitle,
              style: const TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onExpansionChanged: (isExpanding) {
            if (isExpanding && _episodesByGroup[actualIndex] == null) {
              final page = actualIndex + 1; // Calculate page here
              _fetchEpisodesForGroup(actualIndex, page); // Pass page directly
            }
          },
          children: _isLoadingGroup[actualIndex] ?? false
              ? [const Center(child: CircularProgressIndicator())]
              : _episodesByGroup[actualIndex]
                        ?.map((episode) => _buildEpisodeTile(context, episode))
                        .toList() ??
                    [],
        ),
      ),
    );
  }

  Future<void> _fetchEpisodesForGroup(
    int groupIndex,
    int requestedPage, { // Renamed page to requestedPage to avoid confusion
    int? limit,
  }) async {
    setState(() {
      _isLoadingGroup[groupIndex] = true;
    });

    final actualLimit = limit ?? 25;
    final totalPages = (widget.totalEpisodes / actualLimit).ceil();

    // Calculate the actual page to request from the API
    // If requestedPage is 1 (for episodes 1-50), we need to request the last page from the API.
    // If requestedPage is totalPages (for latest episodes), we need to request page 1 from the API.
    final apiPage = totalPages - requestedPage + 1;

    try {
      final response = await ref.read(
        episodeListProvider((
          slug: widget.slug,
          page: apiPage, // Use the adjusted apiPage
          limit: actualLimit,
        )).future,
      );
      print('Fetched episodes length: ${response.episodes.length}');
      final sortedEpisodes = _sortEpisodes(response.episodes);
      setState(() {
        _episodesByGroup[groupIndex] = sortedEpisodes;
        _isLoadingGroup[groupIndex] = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGroup[groupIndex] = false;
      });
      // Handle error appropriately
    }
  }

  List<Episode> _sortEpisodes(List<Episode> episodes) {
    final sortedEpisodes = List<Episode>.from(episodes);
    sortedEpisodes.sort((a, b) {
      if (widget.isAscending) {
        return a.episode.compareTo(b.episode);
      } else {
        return b.episode.compareTo(a.episode);
      }
    });
    return sortedEpisodes;
  }

  Widget _buildEpisodeTile(BuildContext context, Episode episode) {
    final totalEpisodes = widget.totalEpisodes;
    return Padding(
      padding: totalEpisodes <= 25
          ? const EdgeInsets.symmetric(vertical: 3, horizontal: 16)
          : const EdgeInsets.all(2.0),
      child: ListTile(
        tileColor: const Color(0xDD292929),
        title: Text(
          'Episodio ${episode.episode}',
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.play_circle_outline, color: Colors.red),
        onTap: () => _playEpisode(
          context,
          ref,
          episode,
          _episodesByGroup.values.expand((x) => x).toList(),
        ),
      ),
    );
  }

  void _playEpisode(
    BuildContext context,
    WidgetRef ref,
    Episode episode,
    List<Episode> allEpisodes,
  ) {
    final serversFuture = ref.read(
      episodeServersProvider((
        slug: widget.slug,
        episode: episode.episode,
      )).future,
    );

    ref
        .read(historyProvider.notifier)
        .addOrUpdateHistory(widget.slug, episode.episode);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpisodePlayerScreen(
          serversFuture: serversFuture,
          allEpisodes: allEpisodes,
          currentEpisodeNumber: episode.episode,
          animeSlug: widget.slug,
          episodeId: '',
          videoUrl: '',
        ),
      ),
    );
  }
}
