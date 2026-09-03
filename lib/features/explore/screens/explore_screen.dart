import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_view.dart';
import '../../detail/screens/anime_detail_screen.dart';
import '../controllers/explore_controller.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ExploreController();
    _controller.init();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _controller.loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore & Genres'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () => _controller.init(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Categories Section
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          'Browse Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_controller.isLoadingCategories)
                        const SizedBox(
                          height: 50,
                          child: LoadingView(),
                        )
                      else
                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _controller.categories.length,
                            itemBuilder: (context, index) {
                              final cat = _controller.categories[index];
                              final isSelected =
                                  _controller.selectedCategoryId == cat.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(cat.name),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryColor,
                                  backgroundColor: AppColors.surfaceLightColor,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  onSelected: (selected) {
                                    _controller.selectCategory(
                                        selected ? cat.id : null);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Latest Releases',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Latest Posts Grid
                if (_controller.isLoadingLatest)
                  const SliverFillRemaining(
                    child: LoadingView(message: 'Loading latest releases...'),
                  )
                else if (_controller.latestPosts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No releases found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = _controller.latestPosts[index];
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                                              errorWidget: (context, url, error) =>
                                                  const Icon(
                                                Icons.movie,
                                                color: AppColors.textSecondary,
                                              ),
                                            )
                                          : Container(
                                              color: AppColors.surfaceColor),
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
                                              Colors.black.withValues(alpha: 0.9),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          post.title ?? 'ID: ${post.id}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _controller.latestPosts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                    ),
                  ),

                if (_controller.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryColor),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
