import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/anime_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/floating_search_bar.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/anime_post.dart';
import '../../detail/screens/anime_detail_screen.dart';
import '../controllers/home_controller.dart';
import '../widgets/continue_watching_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.loadHomeData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                switch (_controller.state) {
                  case HomeState.loading:
                  case HomeState.initial:
                    return const LoadingView(message: 'Loading home content...');
                  case HomeState.error:
                    return ErrorView(
                      title: 'Failed to load home content',
                      message: _controller.errorMessage,
                      onRetry: () => _controller.loadHomeData(),
                    );
                  case HomeState.success:
                    final homeData = _controller.homeData!;
                    final postsToDisplay = _controller.latestPosts.isNotEmpty
                        ? _controller.latestPosts
                        : (homeData.sections.isNotEmpty
                            ? homeData.sections.first.posts
                            : <AnimePost>[]);

                    return RefreshIndicator(
                      color: AppColors.primaryColor,
                      onRefresh: () => _controller.loadHomeData(),
                      child: ListView(
                        padding: const EdgeInsets.only(top: 16, bottom: 90),
                        children: [
                          if (_controller.watchHistory.isNotEmpty) ...[
                            ContinueWatchingCarousel(
                              items: _controller.watchHistory,
                              onHistoryUpdated: () =>
                                  _controller.refreshWatchHistory(),
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (postsToDisplay.isNotEmpty) ...[
                            _buildGridPostList(context, postsToDisplay),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    );
                }
              },
            ),

            // Floating Bottom Search Bar
            const FloatingSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPostList(BuildContext context, List<AnimePost> posts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final post = posts[index];
          return AnimeCard(
            post: post,
            width: double.infinity,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimeDetailScreen(
                    animeId: post.id,
                    initialTitle: post.title,
                    initialPoster: post.poster,
                  ),
                ),
              );
              _controller.refreshWatchHistory();
            },
          );
        },
      ),
    );
  }
}
