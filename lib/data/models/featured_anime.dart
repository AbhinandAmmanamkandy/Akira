class FeaturedAnime {
  final int id;
  final String? type;
  final String? title;
  final String? poster;
  final String? status;
  final String? runtime;
  final String? premiered;
  final String? rating;
  final String? age;
  final String? score;
  final String? genres;
  final String? share;

  const FeaturedAnime({
    required this.id,
    this.type,
    this.title,
    this.poster,
    this.status,
    this.runtime,
    this.premiered,
    this.rating,
    this.age,
    this.score,
    this.genres,
    this.share,
  });

  factory FeaturedAnime.fromJson(Map<String, dynamic> json) {
    return FeaturedAnime(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: json['type'] as String?,
      title: json['title'] as String?,
      poster: json['poster'] as String?,
      status: json['status'] as String?,
      runtime: json['runtime'] as String?,
      premiered: json['premiered'] as String?,
      rating: json['rating'] as String?,
      age: json['age'] as String?,
      score: json['score'] as String?,
      genres: json['genres'] as String?,
      share: json['share'] as String?,
    );
  }
}
