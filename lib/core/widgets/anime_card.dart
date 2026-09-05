import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/anime_post.dart';
import '../../data/repositories/anime_title_cache.dart';
import '../theme/app_colors.dart';

class AnimeCard extends StatefulWidget {
  final AnimePost post;
  final VoidCallback onTap;
  final double width;
  final double? height;

  const AnimeCard({
    super.key,
    required this.post,
    required this.onTap,
    this.width = 130,
    this.height,
  });

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  String? _displayTitle;

  @override
  void initState() {
    super.initState();
    _resolveTitle();
  }

  @override
  void didUpdateWidget(covariant AnimeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.title != widget.post.title) {
      _resolveTitle();
    }
  }

  Future<void> _resolveTitle() async {
    final cached = AnimeTitleCache.get(widget.post.id);
    if (cached != null) {
      if (mounted) setState(() => _displayTitle = cached);
      return;
    }

    if (widget.post.title != null &&
        widget.post.title!.isNotEmpty &&
        !widget.post.title!.startsWith('Anime #')) {
      if (mounted) setState(() => _displayTitle = widget.post.title);
      AnimeTitleCache.set(widget.post.id, widget.post.title!);
      return;
    }

    final title =
        await AnimeTitleCache.resolveTitle(widget.post.id, widget.post.title);
    if (mounted) {
      setState(() {
        _displayTitle = title;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _displayTitle ?? widget.post.title ?? 'Loading...';

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: widget.post.poster != null
                          ? CachedNetworkImage(
                              imageUrl: widget.post.poster!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceColor,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceColor,
                                child: const Icon(Icons.broken_image,
                                    color: AppColors.textSecondary),
                              ),
                            )
                          : Container(color: AppColors.surfaceColor),
                    ),
                    if (widget.post.age != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.post.age!,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 34,
              child: Text(
                titleText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
