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
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Stack(
        children: [
          // Background Poster with Gradient (Full Width edge-to-edge)
          SizedBox(
            height: 420,
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
                // Badges Row (Type, Age, Premiered)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (featured.type != null)
                      _buildBadge(featured.type!.toUpperCase(), AppColors.primaryColor),
                    if (featured.age != null)
                      _buildBadge(featured.age!, AppColors.accentColor),
                    if (featured.premiered != null)
                      _buildBadge(featured.premiered!, AppColors.surfaceLightColor, textColor: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 8),
                // Stats Row (Score, Status, Runtime)
                Row(
                  children: [
                    if (featured.score != null || featured.rating != null) ...[
                      const Icon(Icons.star_rounded, color: AppColors.starRatingColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        featured.score ?? featured.rating ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    if (featured.status != null) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        featured.status!,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 14),
                    ],
                    if (featured.runtime != null)
                      Text(
                        featured.runtime!,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                  ],
                ),
                // Genres
                if (featured.genres != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    featured.genres!,
                    style: const TextStyle(
                      color: AppColors.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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

  Widget _buildBadge(String text, Color bgColor, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
