import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/anime_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/anime_post.dart';
import '../../detail/screens/anime_detail_screen.dart';
import '../controllers/home_controller.dart';
import '../widgets/featured_hero.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appSubtitle,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadHomeData(),
          ),
        ],
      ),
      body: ListenableBuilder(
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
              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () => _controller.loadHomeData(),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    if (homeData.featured != null) ...[
                      FeaturedHero(featured: homeData.featured!),
                      const SizedBox(height: 24),
                    ],
                    for (var section in homeData.sections) ...[
                      if (section.posts.isNotEmpty) ...[
                        SectionHeader(title: section.name),
                        const SizedBox(height: 12),
                        _buildHorizontalPostList(context, section.posts),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildHorizontalPostList(BuildContext context, List<AnimePost> posts) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimeCard(
              post: post,
              width: 130,
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
            ),
          );
        },
      ),
    );
  }
}
