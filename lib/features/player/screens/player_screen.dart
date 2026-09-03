import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/episode.dart';
import '../controllers/player_controller.dart';

class PlayerScreen extends StatefulWidget {
  final int animeId;
  final String animeTitle;
  final String? animePoster;
  final Episode selectedEpisode;
  final List<Episode> allEpisodes;

  const PlayerScreen({
    super.key,
    required this.animeId,
    required this.animeTitle,
    this.animePoster,
    required this.selectedEpisode,
    required this.allEpisodes,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlayerController(
      animeId: widget.animeId,
      animeTitle: widget.animeTitle,
      animePoster: widget.animePoster,
      initialEpisode: widget.selectedEpisode,
      allEpisodes: widget.allEpisodes,
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final currentIndex = widget.allEpisodes
            .indexWhere((e) => e.id == _controller.currentEpisode.id);
        final hasPrev = currentIndex > 0;
        final hasNext =
            currentIndex >= 0 && currentIndex < widget.allEpisodes.length - 1;

        if (_controller.isFullScreen) {
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
                  style:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_controller.currentEpisode.name} (${_controller.currentEpisode.number})',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildVideoDisplayArea(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceLightColor,
                              foregroundColor: hasPrev
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed:
                                hasPrev ? _controller.goToPreviousEpisode : null,
                            icon: const Icon(Icons.skip_previous_rounded),
                            label: const Text('PREV EPISODE'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: hasNext
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed:
                                hasNext ? _controller.goToNextEpisode : null,
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text('NEXT EPISODE'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.dns_rounded,
                            color: AppColors.primaryColor, size: 20),
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
                    if (_controller.isLoadingServers)
                      const LoadingView()
                    else if (_controller.servers.isEmpty)
                      const Text('No servers available',
                          style: TextStyle(color: AppColors.textSecondary))
                    else ...[
                      if (_controller.servers
                          .any((s) => s.lang.toLowerCase() == 'sub')) ...[
                        const Text(
                          'SUBTITLED (SUB)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _controller.servers
                              .where((s) => s.lang.toLowerCase() == 'sub')
                              .map((server) => _buildServerChip(server))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_controller.servers
                          .any((s) => s.lang.toLowerCase() == 'dub')) ...[
                        const Text(
                          'DUBBED (DUB)',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _controller.servers
                              .where((s) => s.lang.toLowerCase() == 'dub')
                              .map((server) => _buildServerChip(server))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.surfaceLightColor),
                    const SizedBox(height: 16),
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
                          final isCurrent =
                              ep.id == _controller.currentEpisode.id;
                          return Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () => _controller.selectEpisode(ep),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.primaryColor
                                      : AppColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isCurrent
                                      ? Border.all(
                                          color: Colors.white, width: 2)
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
                                        color: isCurrent
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ep.name,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isCurrent
                                            ? Colors.white70
                                            : AppColors.textSecondary,
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
      },
    );
  }

  Widget _buildVideoDisplayArea() {
    final vp = _controller.videoPlayerController;
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          if (vp != null && vp.value.isInitialized)
            GestureDetector(
              onTap: _controller.toggleControls,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: vp.value.aspectRatio,
                      child: VideoPlayer(vp),
                    ),
                  ),
                  if (_controller.showControls) ...[
                    Container(color: Colors.black.withValues(alpha: 0.4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.replay_10_rounded,
                              color: Colors.white),
                          onPressed: () {
                            final pos = vp.value.position;
                            vp.seekTo(pos - const Duration(seconds: 10));
                          },
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          iconSize: 56,
                          icon: Icon(
                            vp.value.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            if (vp.value.isPlaying) {
                              vp.pause();
                            } else {
                              vp.play();
                            }
                          },
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.forward_10_rounded,
                              color: Colors.white),
                          onPressed: () {
                            final pos = vp.value.position;
                            vp.seekTo(pos + const Duration(seconds: 10));
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        color: Colors.black.withValues(alpha: 0.7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VideoProgressIndicator(
                              vp,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: AppColors.primaryColor,
                                bufferedColor: AppColors.textSecondary,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatDuration(vp.value.position)} / ${_formatDuration(vp.value.duration)}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                                Row(
                                  children: [
                                    PopupMenuButton<double>(
                                      initialValue: _controller.playbackSpeed,
                                      tooltip: 'Playback Speed',
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          '${_controller.playbackSpeed}x',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      onSelected: _controller.setPlaybackSpeed,
                                      itemBuilder: (context) =>
                                          [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                                              .map((s) => PopupMenuItem(
                                                    value: s,
                                                    child: Text('${s}x'),
                                                  ))
                                              .toList(),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _controller.isFullScreen
                                            ? Icons.fullscreen_exit_rounded
                                            : Icons.fullscreen_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: _controller.toggleFullScreen,
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
          if (_controller.isLoadingStream || _controller.isLoadingServers)
            Container(
              color: Colors.black,
              child: const LoadingView(message: 'Loading stream...'),
            ),
          if (_controller.errorMessage != null)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.primaryColor, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _controller.loadEpisodeServers,
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
    final isSelected = _controller.selectedServer?.id == server.id;
    return ChoiceChip(
      label: Text(server.name),
      selected: isSelected,
      selectedColor: AppColors.primaryColor,
      backgroundColor: AppColors.surfaceLightColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          _controller.selectServer(server);
        }
      },
    );
  }
}
