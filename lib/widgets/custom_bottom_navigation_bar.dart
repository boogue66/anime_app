import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ConsumerWidget
import 'package:anime_app/providers/theme_provider.dart'; // Import theme_provider

class CustomBottomNavigationBar extends ConsumerWidget {
  // Change to ConsumerWidget
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef ref
    final themeState = ref.watch(
      themeNotifierProvider,
    ); // Watch themeNotifierProvider

    return BottomNavigationBar(
      type:
          BottomNavigationBarType.fixed, // Para que los labels no desaparezcan
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface, // Fondo oscuro estilo Crunchyroll
      selectedItemColor: themeState.primaryColor, // Use primaryColor
      unselectedItemColor:
          Colors.grey[700], // Color de los items no seleccionados
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      showUnselectedLabels: true,
      elevation: 10,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.home, size: 28),
          ),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.list, size: 28),
          ),
          label: 'Listas',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.grid_view, size: 28),
          ),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.search, size: 28),
          ),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.person, size: 28),
          ),
          label: 'Perfil',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
