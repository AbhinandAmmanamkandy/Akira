import 'anime_post.dart';
import 'player_config.dart';

class SeasonItem {
  final int id;
  final String? poster;
  final String? title;

  const SeasonItem({
    required this.id,
    this.poster,
    this.title,
  });

  factory SeasonItem.fromJson(Map<String, dynamic> json) {
    return SeasonItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      poster: json['poster'] as String?,
      title: json['title'] as String?,
    );
  }
}

class AnimeDetail {
  final int id;
  final String? type;
  final String? title;
  final String? poster;
  final String? overview;
  final String? status;
  final String? runtime;
  final String? premiered;
  final String? rating;
  final String? age;
  final String? score;
  final String? genres;
  final String? share;
  final List<SeasonItem> seasons;
  final List<AnimePost> related;
  final List<AnimePost> similar;
  final PlayerConfig? playerConfig;

  const AnimeDetail({
    required this.id,
    this.type,
    this.title,
    this.poster,
    this.overview,
    this.status,
    this.runtime,
    this.premiered,
    this.rating,
    this.age,
    this.score,
    this.genres,
    this.share,
    required this.seasons,
    required this.related,
    required this.similar,
    this.playerConfig,
  });

  factory AnimeDetail.fromJson(Map<String, dynamic> json) {
    var rawSeasons = json['seasons'] as List? ?? [];
    var rawRelated = json['related'] as List? ?? [];
    var rawSimilar = json['similar'] as List? ?? [];

    return AnimeDetail(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: json['type'] as String?,
      title: json['title'] as String?,
      poster: json['poster'] as String?,
      overview: json['overview'] as String?,
      status: json['status'] as String?,
      runtime: json['runtime'] as String?,
      premiered: json['premiered'] as String?,
      rating: json['rating'] as String?,
      age: json['age'] as String?,
      score: json['score'] as String?,
      genres: json['genres'] as String?,
      share: json['share'] as String?,
      seasons: rawSeasons.map((e) => SeasonItem.fromJson(e as Map<String, dynamic>)).toList(),
      related: rawRelated.map((e) => AnimePost.fromJson(e as Map<String, dynamic>)).toList(),
      similar: rawSimilar.map((e) => AnimePost.fromJson(e as Map<String, dynamic>)).toList(),
      playerConfig: json['playerConfig'] != null
          ? PlayerConfig.fromJson(json['playerConfig'] as Map<String, dynamic>)
          : null,
    );
  }
}
