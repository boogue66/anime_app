import 'package:anime_app/providers/user_provider.dart';
import 'package:anime_app/screens/anime_categories_screen.dart';
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
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/home',
        builder: (context, agstate) => HomeScreen(initialIndex: agstate.extra as int? ?? 0),
      ),
      GoRoute(path: '/list', builder: (context, state) => const AnimeListScreen()),
      GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
      GoRoute(path: '/categories', builder: (context, state) => AnimeCategoriesScreen()),
      GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const UserProfileScreen()),
      GoRoute(
        path: '/anime/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return AnimeDetailScreen(slug: slug);
        },
      ),
      GoRoute(
        path: '/episode/:id',
        builder: (context, state) {
          return EpisodePlayerScreen(
            serversFuture: Future.value([]),
            allEpisodes: [],
            animeSlug: '',
            currentEpisodeNumber: 0,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = userState.asData?.value != null;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
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
