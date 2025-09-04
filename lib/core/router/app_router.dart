import 'package:anime_app/providers/user_provider.dart';
import 'package:anime_app/screens/anime_detail_screen.dart';
import 'package:anime_app/screens/anime_list_screen.dart';
import 'package:anime_app/screens/episode_player_screen.dart';
import 'package:anime_app/screens/history_screen.dart';
import 'package:anime_app/screens/home_screen.dart';
import 'package:anime_app/screens/login_screen.dart';
import 'package:anime_app/screens/register_screen.dart';
import 'package:anime_app/screens/search_screen.dart';
import 'package:anime_app/screens/user_profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final userState = ref.watch(userProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/list',
        builder: (context, state) => const AnimeListScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/anime/:id',
        builder: (context, state) {
          final animeId = state.pathParameters['id']!;
          return AnimeDetailScreen(id: animeId, slug: '');
        },
      ),
      GoRoute(
        path: '/episode/:id',
        builder: (context, state) {
          final episodeId = state.pathParameters['id']!;
          return EpisodePlayerScreen(
            episodeId: episodeId,
            videoUrl: '',
            allEpisodes: [],
            animeSlug: '',
            currentEpisodeNumber: 0,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = userState.asData?.value != null;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
  );
});