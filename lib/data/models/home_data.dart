import 'anime_post.dart';

class HomeSection {
  final String name;
  final List<AnimePost> posts;

  const HomeSection({
    required this.name,
    required this.posts,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    var rawPosts = json['posts'] as List? ?? [];
    return HomeSection(
      name: json['name'] as String? ?? 'Section',
      posts: rawPosts.map((e) => AnimePost.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class HomeData {
  final List<HomeSection> sections;

  const HomeData({
    required this.sections,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    var rawSections = json['sections'] as List? ?? [];
    return HomeData(
      sections: rawSections
          .map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
