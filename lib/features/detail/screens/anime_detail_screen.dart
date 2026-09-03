import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/badge_tag.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../player/screens/player_screen.dart';
import '../controllers/anime_detail_controller.dart';
import '../widgets/episode_list_item.dart';

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
                        const SizedBox(height: 20),
                        const LoadingView(),
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
                              ),
                            if (detail.status != null)
                              BadgeTag(
                                text: detail.status!,
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
                      ],

                      // Episodes Header
                      SectionHeader(
                        title: 'Episodes (${_controller.episodes.length})',
                      ),
                      const SizedBox(height: 12),

                      if (_controller.episodes.length > 5)
                        TextField(
                          controller: _episodeSearchController,
                          style:
                              const TextStyle(fontSize: 13, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search episode number or title...',
                            prefixIcon: const Icon(Icons.search,
                                size: 18, color: AppColors.textSecondary),
                            suffixIcon: _episodeSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        size: 18, color: AppColors.textSecondary),
                                    onPressed: () {
                                      _episodeSearchController.clear();
                                      _controller.filterEpisodes('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: _controller.filterEpisodes,
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Episodes List
              if (_controller.isLoadingEpisodes)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: LoadingView(message: 'Loading episodes...'),
                  ),
                )
              else if (_controller.filteredEpisodes.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No episodes available',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ep = _controller.filteredEpisodes[index];
                        return EpisodeListItem(
                          episode: ep,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  animeId: widget.animeId,
                                  animeTitle: title,
                                  selectedEpisode: ep,
                                  allEpisodes: _controller.episodes,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: _controller.filteredEpisodes.length,
                    ),
                  ),
                ),

              // Similar Anime Section
              if (detail != null && detail.similar.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 24, 0, 12),
                    child: SectionHeader(title: 'Similar Anime'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: detail.similar.length,
                      itemBuilder: (context, index) {
                        final post = detail.similar[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnimeDetailScreen(
                                  animeId: post.id,
                                  initialTitle: post.title,
                                  initialPoster: post.poster,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: post.poster != null
                                  ? CachedNetworkImage(
                                      imageUrl: post.poster!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(color: AppColors.surfaceColor),
                                      errorWidget: (context, url, error) =>
                                          Container(color: AppColors.surfaceColor),
                                    )
                                  : Container(color: AppColors.surfaceColor),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}
