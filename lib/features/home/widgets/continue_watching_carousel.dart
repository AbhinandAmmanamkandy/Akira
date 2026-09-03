import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/episode.dart';
import '../../../data/models/watch_history_item.dart';
import '../../../data/repositories/anime_repository.dart';
import '../../player/screens/player_screen.dart';

class ContinueWatchingCarousel extends StatelessWidget {
  final List<WatchHistoryItem> items;
  final VoidCallback onHistoryUpdated;

  const ContinueWatchingCarousel({
    super.key,
    required this.items,
    required this.onHistoryUpdated,
  });

  Future<void> _onTapItem(BuildContext context, WatchHistoryItem item) async {
    // Show loading spinner dialog while fetching episode list
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );

    try {
      final repository = AnimeRepository();
      List<Episode> episodes = [];
      try {
        episodes = await repository.fetchEpisodes(item.animeId);
      } catch (_) {}

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      final targetEpisode = episodes.firstWhere(
        (ep) => ep.id == item.episodeId,
        orElse: () => Episode(
          id: item.episodeId,
          name: item.episodeName,
          number: item.episodeNumber,
          filler: false,
        ),
      );

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              animeId: item.animeId,
              animeTitle: item.animeTitle,
              animePoster: item.animePoster,
              selectedEpisode: targetEpisode,
              allEpisodes: episodes.isNotEmpty ? episodes : [targetEpisode],
            ),
          ),
        );
        onHistoryUpdated();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch player: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Continue Watching'),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _onTapItem(context, item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.surfaceLightColor,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: item.animePoster != null
                                    ? CachedNetworkImage(
                                        imageUrl: item.animePoster!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: AppColors.surfaceColor,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: AppColors.surfaceColor,
                                          child: const Icon(Icons.movie,
                                              color: AppColors.textSecondary),
                                        ),
                                      )
                                    : Container(color: AppColors.surfaceColor),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.85),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 10,
                                right: 10,
                                child: Text(
                                  item.animeTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'EP ${item.episodeNumber} • ${item.episodeName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${(item.progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        LinearProgressIndicator(
                          value: item.progress,
                          backgroundColor: AppColors.surfaceLightColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                          minHeight: 3,
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
    );
  }
}
