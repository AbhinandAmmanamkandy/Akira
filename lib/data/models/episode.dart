class Episode {
  final String id;
  final String name;
  final String number;
  final bool filler;

  const Episode({
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

  const EpisodeServer({
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
