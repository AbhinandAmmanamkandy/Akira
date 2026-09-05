import '../repositories/anime_title_cache.dart';

class AnimePost {
  final int id;
  final String? poster;
  final String? title;
  final String? age;

  const AnimePost({
    required this.id,
    this.poster,
    this.title,
    this.age,
  });

  factory AnimePost.fromJson(Map<String, dynamic> json) {
    final int parsedId = json['id'] is int
        ? json['id']
        : int.parse(json['id'].toString());

    String? parsedTitle = json['title'] as String? ??
        json['name'] as String? ??
        json['post_title'] as String? ??
        json['postTitle'] as String? ??
        json['anime_title'] as String? ??
        json['animeTitle'] as String? ??
        json['title_english'] as String? ??
        json['english'] as String? ??
        json['title_romaji'] as String? ??
        json['romaji'] as String?;

    if (parsedTitle != null && parsedTitle.isNotEmpty) {
      AnimeTitleCache.set(parsedId, parsedTitle);
    } else if (AnimeTitleCache.get(parsedId) != null) {
      parsedTitle = AnimeTitleCache.get(parsedId);
    }

    return AnimePost(
      id: parsedId,
      poster: (json['poster'] as String?) ?? (json['image'] as String?),
      title: parsedTitle,
      age: json['age'] as String?,
    );
  }
}
