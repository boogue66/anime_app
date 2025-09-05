import 'package:anime_app/providers/theme_provider.dart';
import 'package:anime_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final themeState = ref.watch(themeNotifierProvider);

    return Scaffold(
      body: userState.when(
        data: (user) {
          if (user != null) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text(
                          "Usuario: ${user.username}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Email: ${user.email}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Modo Oscuro'),
                        value: themeState.isDarkMode,
                        onChanged: (value) {
                          if (value) {
                            ref
                                .read(themeNotifierProvider.notifier)
                                .setDarkTheme();
                          } else {
                            ref
                                .read(themeNotifierProvider.notifier)
                                .setLightTheme();
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Color Primario'),
                        trailing: CircleAvatar(
                          backgroundColor: themeState.primaryColor,
                          radius: 15,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final List<Color> colors = [
                                const Color(0xFFB0BEC5), // Gris azulado
                                const Color(0xFF90CAF9), // Azul suave
                                const Color(0xFF80CBC4), // Verde agua
                                const Color(0xFFA5D6A7), // Verde suave
                                const Color(0xFFFFE082), // Amarillo suave
                                const Color(0xFFFFCCBC), // Durazno claro
                                const Color(0xFFF8BBD0), // Rosa claro
                                const Color(0xFFCE93D8), // Lila suave
                              ];
                              return AlertDialog(
                                title: const Text('Elija un color'),
                                content: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: colors.map((color) {
                                    return GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(
                                              themeNotifierProvider.notifier,
                                            )
                                            .setPrimaryColor(color);
                                        Navigator.of(context).pop();
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: color,
                                        radius: 20,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Salir'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // 👇 Botón siempre abajo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Salir',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        ref.read(userProvider.notifier).logout();
                        context.go('/login');
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const Text('No user logged in.');
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
