import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../detail/screens/anime_detail_screen.dart';
import '../controllers/search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchAnimeController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = SearchAnimeController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search anime (e.g. One Piece)...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _controller.clearSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: _controller.onSearchQueryChanged,
          onSubmitted: (query) {
            if (query.trim().isNotEmpty) {
              _controller.performSearch(query.trim());
            }
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _buildSearchBody(),
      ),
    );
  }

  Widget _buildSearchBody() {
    switch (_controller.state) {
      case SearchState.searching:
        return const LoadingView(message: 'Searching...');
      case SearchState.error:
        return ErrorView(
          title: 'Search failed',
          message: _controller.errorMessage,
        );
      case SearchState.idle:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 80, color: AppColors.surfaceLightColor),
              SizedBox(height: 16),
              Text(
                'Search for your favorite anime',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.searchResults.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.68,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final post = _controller.searchResults[index];
            return GestureDetector(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: post.poster != null
                          ? CachedNetworkImage(
                              imageUrl: post.poster!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceColor,
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.movie,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : Container(color: AppColors.surfaceColor),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.95),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          post.title ?? 'ID: ${post.id}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
    }
  }
}
