import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/featured_anime.dart';
import '../../detail/screens/anime_detail_screen.dart';

class FeaturedHero extends StatelessWidget {
  final FeaturedAnime featured;

  const FeaturedHero({
    super.key,
    required this.featured,
  });

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimeDetailScreen(
          animeId: featured.id,
          initialTitle: featured.title,
          initialPoster: featured.poster,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.60;

    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Stack(
        children: [
          // Background Poster with Gradient (Full Width edge-to-edge, 60% screen height)
          SizedBox(
            height: heroHeight,
            width: double.infinity,
            child: featured.poster != null
                ? CachedNetworkImage(
                    imageUrl: featured.poster!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.surfaceColor),
                    errorWidget: (context, url, error) => const Icon(Icons.movie, size: 50),
                  )
                : Container(color: AppColors.surfaceColor),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.backgroundColor.withValues(alpha: 0.6),
                    AppColors.backgroundColor.withValues(alpha: 0.95),
                    AppColors.backgroundColor,
                  ],
                  stops: const [0.2, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),
          // Content with horizontal padding
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  featured.title ?? 'Featured Anime',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Genres / Categories Chips right below anime name
                if (featured.genres != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: featured.genres!
                        .split(',')
                        .map((genre) => genre.trim())
                        .where((genre) => genre.isNotEmpty)
                        .map((genre) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceColor.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primaryColor.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                // Row 1: Score (8.7), Age (PG-13), Type (TV) with professional vibrant colors
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (featured.score != null || featured.rating != null)
                      _buildInlineMeta(Icons.star_rounded, featured.score ?? featured.rating ?? '', iconColor: const Color(0xFFF59E0B), isHighlight: true), // Amber Gold
                    if (featured.age != null)
                      _buildInlineMeta(Icons.explicit_rounded, featured.age!, iconColor: const Color(0xFFF97316)), // Warm Orange
                    if (featured.type != null)
                      _buildInlineMeta(Icons.ondemand_video_rounded, featured.type!.toUpperCase(), iconColor: const Color(0xFF0EA5E9)), // Vibrant Sky Blue
                  ],
                ),
                const SizedBox(height: 6),
                // Row 2: Runtime (24m), Status (Currently Airing), Premiered (Fall 1999) with professional vibrant colors
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (featured.runtime != null)
                      _buildInlineMeta(Icons.schedule_rounded, featured.runtime!, iconColor: const Color(0xFFA855F7)), // Soft Monarch Purple
                    if (featured.status != null)
                      _buildInlineMeta(Icons.live_tv_rounded, featured.status!, iconColor: const Color(0xFF10B981)), // Emerald Mint Green
                    if (featured.premiered != null)
                      _buildInlineMeta(Icons.event_rounded, featured.premiered!, iconColor: const Color(0xFF818CF8)), // Teal Aqua
                  ],
                ),
                const SizedBox(height: 16),
                // Watch Now Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: AppColors.primaryColor.withValues(alpha: 0.5),
                    ),
                    onPressed: () => _navigateToDetail(context),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text(
                      'WATCH NOW',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineMeta(IconData icon, String text, {Color iconColor = AppColors.primaryColor, bool isHighlight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: isHighlight ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
