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
    return AnimePost(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      poster: json['poster'] as String?,
      title: json['title'] as String?,
      age: json['age'] as String?,
    );
  }
}
