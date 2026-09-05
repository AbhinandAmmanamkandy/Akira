import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/badge_tag.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../player/screens/player_screen.dart';
import '../controllers/anime_detail_controller.dart';

class AnimeDetailScreen extends StatefulWidget {
  final int animeId;
  final String? initialTitle;
  final String? initialPoster;

  const AnimeDetailScreen({
    super.key,
    required this.animeId,
    this.initialTitle,
    this.initialPoster,
  });

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  late final AnimeDetailController _controller;
  final TextEditingController _episodeSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimeDetailController(animeId: widget.animeId);
    _controller.loadData();
  }

  @override
  void dispose() {
    _episodeSearchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final detail = _controller.detail;
        final title = detail?.title ?? widget.initialTitle ?? 'Anime Detail';
        final poster = detail?.poster ?? widget.initialPoster;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with Poster
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.backgroundColor,
                actions: [
                  if (detail?.share != null)
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: detail!.share!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share link copied to clipboard')),
                        );
                      },
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      poster != null
                          ? CachedNetworkImage(
                              imageUrl: poster,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: AppColors.surfaceColor),
                              errorWidget: (context, url, error) =>
                                  Container(color: AppColors.surfaceColor),
                            )
                          : Container(color: AppColors.surfaceColor),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              AppColors.backgroundColor.withValues(alpha: 0.8),
                              AppColors.backgroundColor,
                            ],
                            stops: const [0.0, 0.4, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Metadata & Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_controller.isLoadingDetail) ...[
                        const SizedBox(height: 50),
                        const LoadingView(),
                        const SizedBox(height: 50),
                      ] else if (_controller.errorMessage != null &&
                          detail == null) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Failed to load details: ${_controller.errorMessage}',
                          style: const TextStyle(color: AppColors.primaryColor),
                        ),
                      ] else if (detail != null) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (detail.type != null)
                              BadgeTag(
                                text: detail.type!.toUpperCase(),
                                backgroundColor: AppColors.primaryColor,
                              ),
                            if (detail.score != null)
                              BadgeTag(
                                text: detail.score!,
                                backgroundColor: Colors.amber.shade800,
                                icon: Icons.star_rounded,
                              ),
                            if (detail.age != null)
                              BadgeTag(
                                text: detail.age!,
                                backgroundColor: AppColors.surfaceLightColor,
                                icon: Icons.explicit_rounded,
                              ),
                            if (detail.status != null)
                              BadgeTag(
                                text: detail.status!,
                                backgroundColor: AppColors.surfaceLightColor,
                              ),
                            if (detail.premiered != null)
                              BadgeTag(
                                text: detail.premiered!,
                                backgroundColor: AppColors.surfaceLightColor,
                                icon: Icons.calendar_month_rounded,
                              ),
                            if (detail.rating != null)
                              BadgeTag(
                                text: detail.rating!,
                                backgroundColor: AppColors.surfaceLightColor,
                              ),
                            if (detail.runtime != null)
                              BadgeTag(
                                text: detail.runtime!,
                                backgroundColor: AppColors.surfaceLightColor,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (detail.genres != null) ...[
                          Text(
                            detail.genres!,
                            style: const TextStyle(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (detail.overview != null &&
                            detail.overview!.isNotEmpty) ...[
                          const Text(
                            'Synopsis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            detail.overview!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        if (_controller.isLoadingEpisodes)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                              ),
                            ),
                          )
                        else if (_controller.episodes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final targetEpisode =
                                      _controller.resumeEpisode ?? _controller.episodes.first;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlayerScreen(
                                        animeId: widget.animeId,
                                        animeTitle: title,
                                        animePoster: poster,
                                        selectedEpisode: targetEpisode,
                                        allEpisodes: _controller.episodes,
                                      ),
                                    ),
                                  ).then((_) => _controller.loadData());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.play_circle_fill_rounded, size: 28),
                                label: Text(
                                  _controller.lastWatchHistory != null
                                      ? 'CONTINUE EPISODE ${_controller.resumeEpisode?.number ?? ''}'
                                      : 'WATCH NOW',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'No episodes available',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                      ],

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),



              // Seasons Section
              if (detail != null && detail.seasons.isNotEmpty)
                ..._buildHorizontalList('Seasons', detail.seasons),

              // Related Anime Section
              if (detail != null && detail.related.isNotEmpty)
                ..._buildHorizontalList('Related Anime', detail.related),

              // Similar Anime Section
              if (detail != null && detail.similar.isNotEmpty)
                ..._buildHorizontalList('Similar Anime', detail.similar),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildHorizontalList(String title, List<dynamic> items) {
    if (items.isEmpty) return [];

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
          child: SectionHeader(title: title),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final int itemId = item.id;
              final String? itemTitle = item.title;
              final String? itemPoster = item.poster;

              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailScreen(
                        animeId: itemId,
                        initialTitle: itemTitle,
                        initialPoster: itemPoster,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: itemPoster != null
                              ? CachedNetworkImage(
                                  imageUrl: itemPoster,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) =>
                                      Container(color: AppColors.surfaceColor),
                                  errorWidget: (context, url, error) =>
                                      Container(color: AppColors.surfaceColor),
                                )
                              : Container(color: AppColors.surfaceColor, width: double.infinity),
                        ),
                      ),
                      if (itemTitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          itemTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }
}
