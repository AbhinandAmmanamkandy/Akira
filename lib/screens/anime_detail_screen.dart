import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'player_screen.dart';

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
  final ApiService _apiService = ApiService();

  AnimeDetail? _detail;
  List<Episode> _episodes = [];
  List<Episode> _filteredEpisodes = [];

  bool _isLoadingDetail = true;
  bool _isLoadingEpisodes = true;
  String? _errorMessage;

  final TextEditingController _episodeSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _episodeSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoadingDetail = true;
      _isLoadingEpisodes = true;
      _errorMessage = null;
    });

    _fetchAnimeDetail();
    _fetchEpisodes();
  }

  Future<void> _fetchAnimeDetail() async {
    try {
      final detail = await _apiService.getAnimeDetail(widget.animeId);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoadingDetail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _fetchEpisodes() async {
    try {
      final episodes = await _apiService.getEpisodes(widget.animeId);
      if (mounted) {
        setState(() {
          _episodes = episodes;
          _filteredEpisodes = episodes;
          _isLoadingEpisodes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingEpisodes = false;
        });
      }
    }
  }

  void _filterEpisodes(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredEpisodes = _episodes;
      });
    } else {
      setState(() {
        _filteredEpisodes = _episodes.where((ep) {
          final q = query.toLowerCase();
          return ep.name.toLowerCase().contains(q) || ep.number.toLowerCase().contains(q);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?.title ?? widget.initialTitle ?? 'Anime Detail';
    final poster = _detail?.poster ?? widget.initialPoster;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Poster
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          placeholder: (context, url) => Container(color: AppTheme.surfaceColor),
                          errorWidget: (context, url, error) => Container(color: AppTheme.surfaceColor),
                        )
                      : Container(color: AppTheme.surfaceColor),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          AppTheme.backgroundColor.withValues(alpha: 0.8),
                          AppTheme.backgroundColor,
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
                  if (_isLoadingDetail) ...[
                    const SizedBox(height: 20),
                    const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    ),
                  ] else if (_errorMessage != null && _detail == null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Failed to load details: $_errorMessage',
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ] else if (_detail != null) ...[
                    // Badges (Type, Rating, Age, Score)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (_detail!.type != null)
                          _buildBadge(_detail!.type!.toUpperCase(), AppTheme.primaryColor),
                        if (_detail!.score != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade800,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  _detail!.score!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_detail!.age != null)
                          _buildBadge(_detail!.age!, AppTheme.surfaceLightColor),
                        if (_detail!.status != null)
                          _buildBadge(_detail!.status!, AppTheme.surfaceLightColor),
                        if (_detail!.runtime != null)
                          _buildBadge(_detail!.runtime!, AppTheme.surfaceLightColor),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Genres
                    if (_detail!.genres != null) ...[
                      Text(
                        _detail!.genres!,
                        style: const TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Overview / Synopsis
                    if (_detail!.overview != null && _detail!.overview!.isNotEmpty) ...[
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
                        _detail!.overview!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],

                  // Episodes Header & Search
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Episodes (${_episodes.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Episode Bar
                  if (_episodes.length > 5)
                    TextField(
                      controller: _episodeSearchController,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search episode number or title...',
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
                        suffixIcon: _episodeSearchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppTheme.textSecondary),
                                onPressed: () {
                                  _episodeSearchController.clear();
                                  _filterEpisodes('');
                                },
                              )
                            : null,
                      ),
                      onChanged: _filterEpisodes,
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Episodes List
          if (_isLoadingEpisodes)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              ),
            )
          else if (_filteredEpisodes.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No episodes available',
                    style: TextStyle(color: AppTheme.textSecondary),
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
                    final ep = _filteredEpisodes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: AppTheme.surfaceColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ep.filler ? Colors.orange.withValues(alpha: 0.2) : AppTheme.primaryColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              ep.number,
                              style: TextStyle(
                                color: ep.filler ? Colors.orange : AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          ep.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: ep.filler
                            ? const Text(
                                'Filler Episode',
                                style: TextStyle(color: Colors.orange, fontSize: 11),
                              )
                            : null,
                        trailing: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlayerScreen(
                                animeId: widget.animeId,
                                animeTitle: title,
                                selectedEpisode: ep,
                                allEpisodes: _episodes,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: _filteredEpisodes.length,
                ),
              ),
            ),

          // Similar Anime Section
          if (_detail != null && _detail!.similar.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Similar Anime',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _detail!.similar.length,
                  itemBuilder: (context, index) {
                    final post = _detail!.similar[index];
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
                                  placeholder: (context, url) => Container(color: AppTheme.surfaceColor),
                                  errorWidget: (context, url, error) => Container(color: AppTheme.surfaceColor),
                                )
                              : Container(color: AppTheme.surfaceColor),
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
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
