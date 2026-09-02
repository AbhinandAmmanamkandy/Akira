class AnimePost {
  final int id;
  final String? poster;
  final String? title;
  final String? age;

  AnimePost({
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

  FeaturedAnime({
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

class HomeSection {
  final String name;
  final List<AnimePost> posts;

  HomeSection({
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
  final FeaturedAnime? featured;
  final List<HomeSection> sections;

  HomeData({
    this.featured,
    required this.sections,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    var rawSections = json['sections'] as List? ?? [];
    return HomeData(
      featured: json['featured'] != null
          ? FeaturedAnime.fromJson(json['featured'] as Map<String, dynamic>)
          : null,
      sections: rawSections
          .map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? 'Category',
    );
  }
}

class SeasonItem {
  final int id;
  final String? poster;
  final String? title;

  SeasonItem({
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

class PlayerConfig {
  final String? playerName;
  final String? playerDesc;
  final String? packageName;
  final String? activityName;
  final String? downloadUrl;
  final String? playerIcon;

  PlayerConfig({
    this.playerName,
    this.playerDesc,
    this.packageName,
    this.activityName,
    this.downloadUrl,
    this.playerIcon,
  });

  factory PlayerConfig.fromJson(Map<String, dynamic> json) {
    return PlayerConfig(
      playerName: json['playerName'] as String?,
      playerDesc: json['playerDesc'] as String?,
      packageName: json['packageName'] as String?,
      activityName: json['activityName'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      playerIcon: json['playerIcon'] as String?,
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

  AnimeDetail({
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

class Episode {
  final String id;
  final String name;
  final String number;
  final bool filler;

  Episode({
    required this.id,
    required this.name,
    required this.number,
    required this.filler,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Episode',
      number: json['number'].toString(),
      filler: json['filler'] as bool? ?? false,
    );
  }
}

class EpisodeServer {
  final String id;
  final String lang;
  final String name;

  EpisodeServer({
    required this.id,
    required this.lang,
    required this.name,
  });

  factory EpisodeServer.fromJson(Map<String, dynamic> json) {
    return EpisodeServer(
      id: json['id'] as String? ?? '',
      lang: json['lang'] as String? ?? 'sub',
      name: json['name'] as String? ?? 'Server',
    );
  }
}
