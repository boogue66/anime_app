import 'package:flutter/material.dart';
import 'package:anime_app/core/router/app_router.dart';
import 'package:anime_app/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: themeState.themeData,
    );
  }
}
