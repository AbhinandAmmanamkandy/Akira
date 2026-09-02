import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/anime.dart';
import '../services/api_service.dart';
import '../theme.dart';

class PlayerScreen extends StatefulWidget {
  final int animeId;
  final String animeTitle;
  final Episode selectedEpisode;
  final List<Episode> allEpisodes;

  const PlayerScreen({
    super.key,
    required this.animeId,
    required this.animeTitle,
    required this.selectedEpisode,
    required this.allEpisodes,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final ApiService _apiService = ApiService();

  late Episode _currentEpisode;
  List<EpisodeServer> _servers = [];
  EpisodeServer? _selectedServer;

  VideoPlayerController? _videoPlayerController;

  bool _isLoadingServers = true;
  bool _isLoadingStream = true;
  bool _showControls = true;
  bool _isFullScreen = false;
  String? _errorMessage;

  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.selectedEpisode;
    _loadEpisodeServers();
  }

  @override
  void dispose() {
    _disposeVideoController();
    _resetOrientation();
    super.dispose();
  }

  void _disposeVideoController() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Future<void> _loadEpisodeServers() async {
    _disposeVideoController();
    setState(() {
      _isLoadingServers = true;
      _isLoadingStream = true;
      _errorMessage = null;
    });

    try {
      final servers = await _apiService.getEpisodeServers(_currentEpisode.id);
      if (mounted) {
        setState(() {
          _servers = servers;
          _isLoadingServers = false;
        });

        if (_servers.isNotEmpty) {
          final defaultServer = _servers.firstWhere(
            (s) => s.lang.toLowerCase() == 'sub',
            orElse: () => _servers.first,
          );
          _selectServer(defaultServer);
        } else {
          setState(() {
            _errorMessage = 'No streaming servers found for this episode.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingServers = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _selectServer(EpisodeServer server) async {
    _disposeVideoController();
    setState(() {
      _selectedServer = server;
      _isLoadingStream = true;
      _errorMessage = null;
    });

    try {
      final iframeUrl = await _apiService.getIframeUrl(server.id);
      final directUrl = await _apiService.extractDirectStreamUrl(iframeUrl);

      if (directUrl != null) {
        if (mounted) {
          await _initNativeVideoPlayer(directUrl);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingStream = false;
            _errorMessage = 'Could not extract direct stream URL for server ${server.name}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStream = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _initNativeVideoPlayer(String streamUrl) async {
    try {
      _disposeVideoController();
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(streamUrl),
        httpHeaders: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Referer': 'https://play.anidb.app/',
        },
      );

      _videoPlayerController = controller;
      await controller.initialize();
      controller.addListener(_videoListener);
      controller.play();

      if (mounted) {
        setState(() {
          _isLoadingStream = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStream = false;
          _errorMessage = 'Failed to load video player: $e';
        });
      }
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      _resetOrientation();
    }
  }

  void _goToPreviousEpisode() {
    final currentIndex = widget.allEpisodes.indexWhere((e) => e.id == _currentEpisode.id);
    if (currentIndex > 0) {
      setState(() {
        _currentEpisode = widget.allEpisodes[currentIndex - 1];
      });
      _loadEpisodeServers();
    }
  }

  void _goToNextEpisode() {
    final currentIndex = widget.allEpisodes.indexWhere((e) => e.id == _currentEpisode.id);
    if (currentIndex >= 0 && currentIndex < widget.allEpisodes.length - 1) {
      setState(() {
        _currentEpisode = widget.allEpisodes[currentIndex + 1];
      });
      _loadEpisodeServers();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.allEpisodes.indexWhere((e) => e.id == _currentEpisode.id);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex >= 0 && currentIndex < widget.allEpisodes.length - 1;

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildVideoDisplayArea(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.animeTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_currentEpisode.name} (${_currentEpisode.number})',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Video Player Box
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildVideoDisplayArea(),
          ),

          // Player Controls & Details Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Episode Navigation Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceLightColor,
                          foregroundColor: hasPrev ? Colors.white : AppTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: hasPrev ? _goToPreviousEpisode : null,
                        icon: const Icon(Icons.skip_previous_rounded),
                        label: const Text('PREV EPISODE'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: hasNext ? Colors.white : AppTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: hasNext ? _goToNextEpisode : null,
                        icon: const Icon(Icons.skip_next_rounded),
                        label: const Text('NEXT EPISODE'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Server Selector Header
                const Row(
                  children: [
                    Icon(Icons.dns_rounded, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Select Server',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_isLoadingServers)
                  const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                else if (_servers.isEmpty)
                  const Text('No servers available', style: TextStyle(color: AppTheme.textSecondary))
                else ...[
                  // SUB Servers
                  if (_servers.any((s) => s.lang.toLowerCase() == 'sub')) ...[
                    const Text(
                      'SUBTITLED (SUB)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _servers
                          .where((s) => s.lang.toLowerCase() == 'sub')
                          .map((server) => _buildServerChip(server))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // DUB Servers
                  if (_servers.any((s) => s.lang.toLowerCase() == 'dub')) ...[
                    const Text(
                      'DUBBED (DUB)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _servers
                          .where((s) => s.lang.toLowerCase() == 'dub')
                          .map((server) => _buildServerChip(server))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                const SizedBox(height: 16),
                const Divider(color: AppTheme.surfaceLightColor),
                const SizedBox(height: 16),

                // Episode List
                const Text(
                  'All Episodes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.allEpisodes.length,
                    itemBuilder: (context, index) {
                      final ep = widget.allEpisodes[index];
                      final isCurrent = ep.id == _currentEpisode.id;
                      return Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            if (!isCurrent) {
                              setState(() {
                                _currentEpisode = ep;
                              });
                              _loadEpisodeServers();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isCurrent ? AppTheme.primaryColor : AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: isCurrent
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'EP ${ep.number}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isCurrent ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ep.name,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isCurrent ? Colors.white70 : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDisplayArea() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Native Video Player
          if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
            GestureDetector(
              onTap: () => setState(() => _showControls = !_showControls),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                  ),

                  // Native Controls Overlay
                  if (_showControls) ...[
                    Container(color: Colors.black.withValues(alpha: 0.4)),
                    // Center Play/Pause & Seek Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                          onPressed: () {
                            final pos = _videoPlayerController!.value.position;
                            _videoPlayerController!.seekTo(pos - const Duration(seconds: 10));
                          },
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          iconSize: 56,
                          icon: Icon(
                            _videoPlayerController!.value.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_videoPlayerController!.value.isPlaying) {
                                _videoPlayerController!.pause();
                              } else {
                                _videoPlayerController!.play();
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                          onPressed: () {
                            final pos = _videoPlayerController!.value.position;
                            _videoPlayerController!.seekTo(pos + const Duration(seconds: 10));
                          },
                        ),
                      ],
                    ),

                    // Bottom Seekbar & Fullscreen Bar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        color: Colors.black.withValues(alpha: 0.7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VideoProgressIndicator(
                              _videoPlayerController!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: AppTheme.primaryColor,
                                bufferedColor: AppTheme.textSecondary,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatDuration(_videoPlayerController!.value.position)} / ${_formatDuration(_videoPlayerController!.value.duration)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                                Row(
                                  children: [
                                    // Speed Picker
                                    PopupMenuButton<double>(
                                      initialValue: _playbackSpeed,
                                      tooltip: 'Playback Speed',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          '${_playbackSpeed}x',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      onSelected: (speed) {
                                        setState(() {
                                          _playbackSpeed = speed;
                                          _videoPlayerController!.setPlaybackSpeed(speed);
                                        });
                                      },
                                      itemBuilder: (context) => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                                          .map((s) => PopupMenuItem(
                                                value: s,
                                                child: Text('${s}x'),
                                              ))
                                          .toList(),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _isFullScreen
                                            ? Icons.fullscreen_exit_rounded
                                            : Icons.fullscreen_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: _toggleFullScreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          if (_isLoadingStream || _isLoadingServers)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 12),
                    Text(
                      'Loading stream...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          if (_errorMessage != null)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.primaryColor, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _loadEpisodeServers,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServerChip(EpisodeServer server) {
    final isSelected = _selectedServer?.id == server.id;
    return ChoiceChip(
      label: Text(server.name),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceLightColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          _selectServer(server);
        }
      },
    );
  }
}
