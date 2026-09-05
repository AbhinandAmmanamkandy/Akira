import 'anime_repository.dart';

class AnimeTitleCache {
  static final Map<int, String> _cache = {};

  static String? get(int id) => _cache[id];

  static void set(int id, String title) {
    if (title.isNotEmpty && !title.startsWith('Anime #')) {
      _cache[id] = title;
    }
  }

  static Future<String> resolveTitle(int id, String? initialTitle) async {
    if (initialTitle != null &&
        initialTitle.isNotEmpty &&
        !initialTitle.startsWith('Anime #')) {
      _cache[id] = initialTitle;
      return initialTitle;
    }

    if (_cache.containsKey(id)) {
      return _cache[id]!;
    }

    try {
      final repository = AnimeRepository();
      final detail = await repository.fetchAnimeDetail(id);
      if (detail.title != null && detail.title!.isNotEmpty) {
        _cache[id] = detail.title!;
        return detail.title!;
      }
    } catch (_) {}

    return 'Anime #$id';
  }
}
