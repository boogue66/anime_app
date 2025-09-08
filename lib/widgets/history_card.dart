import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/models/history_model.dart';
import 'package:anime_app/providers/history_provider.dart';
import 'package:anime_app/screens/anime_detail_screen.dart';

class HistoryCard extends ConsumerWidget {
  final History item;

  const HistoryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anime = item.anime;

    if (anime == null) {
      return const SizedBox.shrink(); // Or a placeholder if anime data is missing
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AnimeDetailScreen(slug: anime.slug)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Anime Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  width: 50,
                  height: 70,
                  imageUrl: anime.poster,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 10),
              // Anime Details
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      anime.title,
                      style: const TextStyle(
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Ultimo Episodio Visto ${item.lastEpisode}',
                      style: const TextStyle(fontSize: 12),
                    ), // Reduced font size
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Estatus: ',
                          style: TextStyle(fontSize: 12),
                        ), // Reduced font size
                        DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          isDense: true,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12, // Reduced font size
                          ),
                          value: item.status,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              ref
                                  .read(historyProvider.notifier)
                                  .addOrUpdateHistory(
                                    anime.slug,
                                    item.lastEpisode,
                                    status: newValue,
                                  );
                            }
                          },
                          items: <String>['watching', 'completed']
                              .map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  ref.read(historyProvider.notifier).removeHistory(anime.slug);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}