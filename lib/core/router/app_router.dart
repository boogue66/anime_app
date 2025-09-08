import 'package:anime_app/providers/user_provider.dart';
import 'package:anime_app/screens/anime_detail_screen.dart';
import 'package:anime_app/screens/anime_genre_screen.dart';
import 'package:anime_app/screens/anime_list_screen.dart';
import 'package:anime_app/screens/episode_player_screen.dart';
import 'package:anime_app/screens/history_screen.dart';
import 'package:anime_app/screens/home_screen.dart';
import 'package:anime_app/screens/login_screen.dart';
import 'package:anime_app/screens/register_screen.dart';
import 'package:anime_app/screens/search_screen.dart';
import 'package:anime_app/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final userState = ref.watch(userProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/list',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AnimeListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
              child: FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SearchScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HistoryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UserProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/anime/:slug',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AnimeDetailScreen(slug: slug),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/episode/:id',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: EpisodePlayerScreen(
              serversFuture: Future.value([]),
              allEpisodes: [],
              animeSlug: '',
              currentEpisodeNumber: 0,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/animes/genre/:genre',
        builder: (context, state) {
          final rawGenre = state.pathParameters['genre']!;
          String genre;
          try {
            genre = Uri.decodeComponent(rawGenre);
          } catch (e) {
            // Fallback to raw genre if decoding fails
            genre = rawGenre;
          }
          return AnimeGenreScreen(genre: genre);
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
