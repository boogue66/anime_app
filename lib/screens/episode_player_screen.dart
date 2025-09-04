// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:anime_app/models/server_model.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_app/providers/anime_provider.dart';
import 'package:anime_app/providers/history_provider.dart';

class EpisodePlayerScreen extends ConsumerStatefulWidget {
  final String videoUrl;
  final List<Episode> allEpisodes; // New: full list of episodes
  final int currentEpisodeNumber; // New: current episode number
  final String animeSlug; // New: anime slug for fetching servers
  final List<String> alternativeVideoUrls;

  const EpisodePlayerScreen({
    super.key,
    required this.videoUrl,
    required this.allEpisodes,
    required this.currentEpisodeNumber,
    required this.animeSlug,
    this.alternativeVideoUrls = const [],
    required String episodeId,
  });

  @override
  ConsumerState<EpisodePlayerScreen> createState() =>
      _EpisodePlayerScreenState();
}

class _EpisodePlayerScreenState extends ConsumerState<EpisodePlayerScreen> {
  late WebViewController _controller;
  late String _currentVideoUrl;
  late List<Episode> _allEpisodes;
  late int _currentEpisodeNumber;
  late String _animeSlug;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _hasError = false;
  String? _finalVideoUrl;

  @override
  void initState() {
    super.initState();
    _currentVideoUrl = widget.videoUrl;
    _allEpisodes = widget.allEpisodes; // Initialize
    _currentEpisodeNumber = widget.currentEpisodeNumber; // Initialize
    _animeSlug = widget.animeSlug; // Initialize

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide status bar and navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeWebView();
    _startHideControlsTimer();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() {
              _hasError =
                  false; // Reset error state when a new page starts loading
            });
          },
          onPageFinished: (String url) {
            // Once the page finishes loading, consider this the final video URL
            if (_finalVideoUrl == null) {
              _finalVideoUrl = url;
              print('Final video URL set to: $_finalVideoUrl');
              // Add to history
              ref
                  .read(historyProvider.notifier)
                  .addOrUpdateHistory(_animeSlug, _currentEpisodeNumber);
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView Error: ${error.description}'); // Log error
            setState(() {
              _hasError = true; // Set error state to true
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // If the final video URL hasn't been determined yet, allow navigation
            if (_finalVideoUrl == null) {
              print('Allowing navigation during initial load: ${request.url}');
              return NavigationDecision.navigate;
            }
            // or the initial currentVideoUrl (for safety/edge cases).
            if (request.url == _finalVideoUrl ||
                request.url == _currentVideoUrl) {
              print('Allowing navigation to known video URL: ${request.url}');
              return NavigationDecision.navigate;
            } else {
              // Prevent any other navigations after the video has started playing
              print('Preventing unwanted navigation: ${request.url}');
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentVideoUrl));
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel(); // Cancel any existing timer
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer(); // Restart timer if controls are shown
    }
  }

  void _selectServer(String url) {
    setState(() {
      _currentVideoUrl = url;
      _hasError = false; // Clear error when a new server is selected
      _finalVideoUrl = null; // Reset final video URL for new server
    });
    _controller.loadRequest(Uri.parse(_currentVideoUrl));
    _startHideControlsTimer(); // Restart timer after server selection
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel(); // Cancel timer on dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Restore system UI to default (show status bar and navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleControlsVisibility,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_hasError && widget.alternativeVideoUrls.isNotEmpty)
              Center(
                child: Container(
                  color: Colors.black.withAlpha(204),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Video failed to load. Select an alternative server:',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: widget.alternativeVideoUrls.map((url) {
                          return ChoiceChip(
                            label: Text(
                              'Server ${widget.alternativeVideoUrls.indexOf(url) + 1}',
                            ),
                            selected: _currentVideoUrl == url,
                            onSelected: (selected) {
                              if (selected) {
                                _selectServer(url);
                              }
                            },
                            selectedColor: Colors.blueAccent,
                            labelStyle: TextStyle(
                              color: _currentVideoUrl == url
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            AnimatedOpacity(
              opacity: 1.0, // Always visible for testing
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: false, // Always allow pointer events for testing
                child: Stack(
                  children: [
                    Positioned(
                      top: 6.0,
                      left: 0.0,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Go back
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Atras'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(180, 100),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6.0,
                      right: 0.0,
                      child: ElevatedButton.icon(
                        onPressed: _playNextEpisode, // Call the new method
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Siguiente Episodio'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(180, 100),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
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

  Future<void> _playNextEpisode() async {
    final currentEpisodeIndex = _allEpisodes.indexWhere(
      (e) => e.episode == _currentEpisodeNumber,
    );
    if (currentEpisodeIndex == -1 ||
        currentEpisodeIndex == _allEpisodes.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is the last episode.')),
      );
      return;
    }

    final nextEpisode = _allEpisodes[currentEpisodeIndex + 1];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final servers = await ref.read(
        episodeServersProvider((
          slug: _animeSlug,
          episode: nextEpisode.episode,
        )).future,
      );
      if (!mounted) return;
      Navigator.pop(context);

      if (servers.isNotEmpty) {
        final swServer = servers.firstWhere(
          (s) => s.server == ServerEnum.SW,
          orElse: () => servers.first,
        );

        setState(() {
          _currentVideoUrl = swServer.url;
          _currentEpisodeNumber = nextEpisode.episode;
          _hasError = false;
          _finalVideoUrl = null; // Reset for new episode
        });
        _controller.loadRequest(Uri.parse(_currentVideoUrl));
        _startHideControlsTimer();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing Episode ${nextEpisode.episode}')),
        );
      } else {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No servers found for the next episode.'),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load next episode: $e')),
      );
    }
  }
}
