import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/anime_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../detail/screens/anime_detail_screen.dart';
import '../controllers/search_anime_controller.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchAnimeController _controller;
  late final TextEditingController _textController;

  static const List<String> _trendingSearches = [
    'One Piece',
    'Solo Leveling',
    'Demon Slayer',
    'Jujutsu Kaisen',
    'Bleach',
    'Naruto',
    'Attack on Titan',
    'Dragon Ball',
  ];

  static const List<String> _popularGenres = [
    'Action',
    'Adventure',
    'Fantasy',
    'Shounen',
    'Sci-Fi',
    'Romance',
    'Comedy',
    'Supernatural',
  ];

  @override
  void initState() {
    super.initState();
    _controller = SearchAnimeController();
    _textController = TextEditingController(text: widget.initialQuery);

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _controller.performSearch(widget.initialQuery!.trim());
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _triggerSearch(String query) {
    _textController.text = query;
    _controller.performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Modern Search Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.surfaceLightColor,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              autofocus: widget.initialQuery == null ||
                                  widget.initialQuery!.isEmpty,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Search anime (e.g. One Piece)...',
                                hintStyle: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                              onChanged: (q) {
                                setState(() {});
                                _controller.onSearchQueryChanged(q);
                              },
                              onSubmitted: (query) {
                                if (query.trim().isNotEmpty) {
                                  _controller.performSearch(query.trim());
                                }
                              },
                            ),
                          ),
                          if (_textController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppColors.textSecondary, size: 20),
                              onPressed: () {
                                _textController.clear();
                                setState(() {});
                                _controller.clearSearch();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Main Body Content
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => _buildSearchBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBody() {
    switch (_controller.state) {
      case SearchState.searching:
        return const LoadingView(message: 'Searching anime...');
      case SearchState.error:
        return ErrorView(
          title: 'Search failed',
          message: _controller.errorMessage,
          onRetry: () {
            if (_textController.text.trim().isNotEmpty) {
              _controller.performSearch(_textController.text.trim());
            }
          },
        );
      case SearchState.idle:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trending Searches Section
              const Row(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: AppColors.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Trending Searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _trendingSearches.map((title) {
                  return ActionChip(
                    label: Text(title),
                    backgroundColor: AppColors.surfaceLightColor,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _triggerSearch(title),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Popular Genres Section
              const Row(
                children: [
                  Icon(Icons.category_rounded,
                      color: AppColors.accentColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Popular Genres',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularGenres.map((genre) {
                  return ActionChip(
                    label: Text(genre),
                    backgroundColor: AppColors.cardColor,
                    labelStyle: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    side: const BorderSide(color: AppColors.surfaceLightColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _triggerSearch(genre),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      case SearchState.success:
        if (_controller.searchResults.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_filter_outlined,
                    size: 80, color: AppColors.surfaceLightColor),
                SizedBox(height: 16),
                Text(
                  'No results found',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Found ${_controller.searchResults.length} results',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _controller.searchResults.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final post = _controller.searchResults[index];
                  return AnimeCard(
                    post: post,
                    width: double.infinity,
                    onTap: () {
                      Navigator.push(
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
                  );
                },
              ),
            ),
          ],
        );
    }
  }
}
