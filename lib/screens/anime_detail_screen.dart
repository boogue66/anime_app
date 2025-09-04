import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/models/server_model.dart';
import 'package:anime_app/providers/anime_provider.dart';
import 'package:anime_app/screens/episode_player_screen.dart';
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
        appBar: AppBar(),
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
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      anime.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
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
                        child: Image.network(
                          width: 200,
                          anime.poster,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

class _EpisodeList extends ConsumerWidget {
  final String slug;
  final bool isAscending;
  final bool isSliver;

  const _EpisodeList({
    required this.slug,
    required this.isAscending,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeListAsyncValue = ref.watch(episodeListProvider(slug));

    return episodeListAsyncValue.when(
      data: (episodes) {
        final sortedEpisodes = _sortEpisodes(episodes);
        if (isSliver) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildEpisodeTile(
                context,
                ref,
                sortedEpisodes[index],
                sortedEpisodes,
              ),
              childCount: sortedEpisodes.length,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: sortedEpisodes.length,
            itemBuilder: (context, index) => _buildEpisodeTile(
              context,
              ref,
              sortedEpisodes[index],
              sortedEpisodes,
            ),
          );
        }
      },
      loading: () => isSliver
          ? const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          : const Center(child: CircularProgressIndicator()),
      error: (err, stack) => isSliver
          ? SliverToBoxAdapter(child: Center(child: Text('Error: $err')))
          : Center(child: Text('Error: $err')),
    );
  }

  List<Episode> _sortEpisodes(List<Episode> episodes) {
    final sortedEpisodes = List<Episode>.from(episodes);
    sortedEpisodes.sort((a, b) {
      if (isAscending) {
        return a.episode.compareTo(b.episode);
      } else {
        return b.episode.compareTo(a.episode);
      }
    });
    return sortedEpisodes;
  }

  Widget _buildEpisodeTile(
    BuildContext context,
    WidgetRef ref,
    Episode episode,
    List<Episode> allEpisodes,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Text('Episodio ${episode.episode}'),
        trailing: const Icon(Icons.play_circle_outline),
        onTap: () => _playEpisode(context, ref, episode, allEpisodes),
      ),
    );
  }

  void _playEpisode(
    BuildContext context,
    WidgetRef ref,
    Episode episode,
    List<Episode> allEpisodes,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final servers = await ref.read(
        episodeServersProvider((slug: slug, episode: episode.episode)).future,
      );
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      if (servers.isNotEmpty) {
        final swServer = servers.firstWhere(
          (s) => s.server == ServerEnum.SW,
          orElse: () => servers.first,
        );

        await ref
            .read(historyProvider.notifier)
            .addOrUpdateHistory(slug, episode.episode);

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpisodePlayerScreen(
              videoUrl: swServer.url,
              allEpisodes: allEpisodes,
              currentEpisodeNumber: episode.episode,
              animeSlug: slug,
              episodeId: '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No servers found for this episode.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading dialog on error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get servers: $e')));
    }
  }
}
