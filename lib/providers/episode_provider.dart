/* import 'package:anime_app/providers/anime_provider.dart';
import 'package:anime_app/services/anime_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Episode {
  final String id;
  final String title;
  Episode({required this.id, required this.title});
}

/// Provider para obtener la lista de episodios de un anime por su ID.
final episodeProvider = FutureProvider.family<List<Episode>, String>((
  ref,
  animeId,
) {
  // Usa el nuevo animeServiceProvider
  final animeService = ref.watch(animeServiceProvider);
  return animeService.getEpisodes(animeId);
});
 */
