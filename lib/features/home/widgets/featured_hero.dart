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
          Container(
            height: 380,
            width: double.infinity,
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.backgroundColor.withValues(alpha: 0.5),
                  AppColors.backgroundColor,
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
            child: featured.poster != null
                ? CachedNetworkImage(
                    imageUrl: featured.poster!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.surfaceColor),
                    errorWidget: (context, url, error) => const Icon(Icons.movie, size: 50),
                  )
                : Container(color: AppColors.surfaceColor),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featured.type != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      featured.type!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  featured.title ?? 'Featured Anime',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (featured.score != null) ...[
                      const Icon(Icons.star_rounded, color: AppColors.starRatingColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        featured.score!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (featured.status != null) ...[
                      Text(
                        featured.status!,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (featured.runtime != null)
                      Text(
                        featured.runtime!,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                  ],
                ),
                if (featured.genres != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    featured.genres!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _navigateToDetail(context),
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text(
                    'WATCH NOW',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
