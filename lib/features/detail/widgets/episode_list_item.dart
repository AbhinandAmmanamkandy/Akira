import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/episode.dart';

class EpisodeListItem extends StatelessWidget {
  final Episode episode;
  final VoidCallback onTap;

  const EpisodeListItem({
    super.key,
    required this.episode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surfaceColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: episode.filler
                ? AppColors.fillerEpisodeColor.withValues(alpha: 0.2)
                : AppColors.primaryColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              episode.number,
              style: TextStyle(
                color: episode.filler
                    ? AppColors.fillerEpisodeColor
                    : AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        title: Text(
          episode.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: episode.filler
            ? const Text(
                'Filler Episode',
                style: TextStyle(color: AppColors.fillerEpisodeColor, fontSize: 11),
              )
            : null,
        trailing: const Icon(
          Icons.play_circle_fill_rounded,
          color: AppColors.primaryColor,
          size: 28,
        ),
        onTap: onTap,
      ),
    );
  }
}
