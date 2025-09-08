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
  final Future<List<ServerElement>> serversFuture;
  final List<Episode> allEpisodes;
  final num currentEpisodeNumber; // Changed to num
  final String animeSlug;
  final int? totalEpisodes;

  const EpisodePlayerScreen({
    super.key,
    required this.serversFuture,
    required this.allEpisodes,
    required this.currentEpisodeNumber,
    required this.animeSlug,
    this.totalEpisodes,
  });

  @override
  ConsumerState<EpisodePlayerScreen> createState() => _EpisodePlayerScreenState();
}

class _EpisodePlayerScreenState extends ConsumerState<EpisodePlayerScreen> {
  WebViewController? _controller;
  String? _currentVideoUrl;
  late List<Episode> _allEpisodes;
  late num _currentEpisodeNumber; // Changed to num
  late String _animeSlug;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _hasError = false;
  String? _finalVideoUrl;
  final bool _isLoadingNextEpisode = false;

  @override
  void initState() {
    super.initState();
    _allEpisodes = widget.allEpisodes;
    _currentEpisodeNumber = widget.currentEpisodeNumber;
    _animeSlug = widget.animeSlug;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideControlsTimer();
  }

  void _initializeWebView(String videoUrl) {
    _currentVideoUrl = videoUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() {
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            if (_finalVideoUrl == null) {
              _finalVideoUrl = url;
              ref
                  .read(historyProvider.notifier)
                  .addOrUpdateHistory(
                    _animeSlug,
                    _currentEpisodeNumber, // Pass num directly
                  );
              setState(() {
                _hasError = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_finalVideoUrl == null) {
              return NavigationDecision.navigate;
            } else if (request.url == _finalVideoUrl || request.url == _currentVideoUrl) {
              return NavigationDecision.navigate;
            } else {
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentVideoUrl!));
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
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
      _startHideControlsTimer();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentEpisodeIndex = _allEpisodes.indexWhere((e) => e.episode == _currentEpisodeNumber);
    final isLastEpisode =
        currentEpisodeIndex == -1 || currentEpisodeIndex == _allEpisodes.length - 1;

    return Scaffold(
      body: FutureBuilder<List<ServerElement>>(
        future: widget.serversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final servers = snapshot.data!;
            final swServer = servers.firstWhere(
              (s) => s.server == ServerEnum.SW,
              orElse: () => servers.first,
            );
            if (_controller == null) {
              _initializeWebView(swServer.url);
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                if (_controller != null) WebViewWidget(controller: _controller!),
                /* if (_hasError)
                  const Center(
                    child: Text(
                      'Error al cargar el video. Intenta de nuevo.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ), */
                if (_isLoadingNextEpisode) const Center(child: CircularProgressIndicator()),

                // Top gesture detector area
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _toggleControlsVisibility,
                    child: Container(
                      height: 120.0, // Height of the tap area
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // Controls
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_showControls,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withAlpha(200), Colors.transparent],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Atras'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                  ),
                                ),
                                minimumSize: const Size(150, 70),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(220),
                                foregroundColor: Colors.black,
                              ),
                            ),
                            if (!isLastEpisode) // Conditionally render the Next Episode button
                              ElevatedButton.icon(
                                onPressed: _playNextEpisode,
                                icon: const Icon(Icons.skip_next),
                                label: const Text(
                                  'Next Episode',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      bottomLeft: Radius.circular(20.0),
                                    ),
                                  ),
                                  minimumSize: const Size(150, 70),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(220),
                                  foregroundColor: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No servers found.'));
          }
        },
      ),
    );
  }

  Future<void> _playNextEpisode() async {
    final currentEpisodeIndex = _allEpisodes.indexWhere((e) => e.episode == _currentEpisodeNumber);
    if (currentEpisodeIndex == -1 || currentEpisodeIndex == _allEpisodes.length - 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This is the last episode.')));
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
          episode: nextEpisode.episode.toInt(), // Use .toInt()
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
          _finalVideoUrl = null;
        });
        ref
            .read(historyProvider.notifier)
            .addOrUpdateHistory(
              _animeSlug,
              _currentEpisodeNumber, // Pass num directly
            );
        _controller?.loadRequest(Uri.parse(_currentVideoUrl!));
        _startHideControlsTimer();

        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Playing Episode ${nextEpisode.episode}')));
      } else {
        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No servers found for the next episode.')));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load next episode: $e')));
    }
  }
}
