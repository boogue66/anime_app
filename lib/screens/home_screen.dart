import 'package:anime_app/providers/anime_provider.dart';
import 'package:anime_app/providers/search_provider.dart';
import 'package:anime_app/screens/anime_categories_screen.dart';
import 'package:anime_app/screens/anime_list_screen.dart';
import 'package:anime_app/screens/history_screen.dart';
import 'package:anime_app/screens/user_profile_screen.dart';
import 'package:anime_app/widgets/anime_card.dart';
import 'package:anime_app/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_isSearching) {
        _isSearching = false;
        ref.read(debouncedSearchProvider.notifier).onSearchChanged('');
        _searchController.clear(); // Clear text field
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeContent(),
      const AnimeListScreen(),
      AnimeCategoriesScreen(),
      const HistoryScreen(),
      const UserProfileScreen(),
    ];

    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  AppBar _buildNormalAppBar() {
    return AppBar(
      title: Text(
        'Animee',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
              _selectedIndex = 0; // Show search results over home content
            });
          },
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            ref.read(debouncedSearchProvider.notifier).onSearchChanged('');
            _searchController.clear(); // Clear text field
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ), // Added style
        decoration: const InputDecoration(
          hintText: 'Buscar animes...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70), // Added hintStyle
        ),
        onChanged: (query) {
          ref.read(debouncedSearchProvider.notifier).onSearchChanged(query);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              // Added setState to close search bar
              _isSearching = false;
              ref.read(debouncedSearchProvider.notifier).onSearchChanged('');
              _searchController.clear(); // Clear text field
            });
          },
        ),
      ],
    );
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final searchQuery = ref.read(debouncedSearchProvider);
        if (searchQuery.isEmpty) {
          ref.read(paginatedAnimesProvider.notifier).fetchNextPage();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(debouncedSearchProvider);

    if (searchQuery.isNotEmpty) {
      return const SearchResults();
    } else {
      return PaginatedAnimes(scrollController: _scrollController);
    }
  }
}

class PaginatedAnimes extends ConsumerWidget {
  final ScrollController scrollController;
  const PaginatedAnimes({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paginatedAnimesProvider);

    if (state.animes.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.animes.isEmpty) {
      return const Center(child: Text('No animes found.'));
    }
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;

    return GridView.builder(
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet
            ? (mediaQuery.orientation == Orientation.portrait ? 4 : 7)
            : 3, // Adjusted for tablet portrait/landscape
        childAspectRatio: mediaQuery.orientation == Orientation.portrait
            ? 0.555
            : 0.62,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: state.animes.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.animes.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final anime = state.animes[index];
        return AnimeCard(anime: anime);
      },
    );
  }
}

class SearchResults extends ConsumerStatefulWidget {
  const SearchResults({super.key});

  @override
  ConsumerState<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<SearchResults> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(paginatedSearchResultProvider.notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedSearchResultProvider);

    if (state.query.isEmpty || state.query.length < 3) {
      return const Center(child: Text('Please enter at least 3 characters.'));
    }

    if (state.animes.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.animes.isEmpty) {
      return const Center(child: Text('No results found.'));
    }
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet
            ? (mediaQuery.orientation == Orientation.portrait ? 4 : 5)
            : 3, // Adjusted for tablet portrait/landscape
        childAspectRatio: 0.555,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: state.animes.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.animes.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final anime = state.animes[index];
        return AnimeCard(anime: anime);
      },
    );
  }
}
