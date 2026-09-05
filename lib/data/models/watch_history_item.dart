class WatchHistoryItem {
  final int animeId;
  final String animeTitle;
  final String? animePoster;
  final String episodeId;
  final String episodeName;
  final String episodeNumber;
  final int positionInSeconds;
  final int durationInSeconds;
  final DateTime lastUpdated;

  const WatchHistoryItem({
    required this.animeId,
    required this.animeTitle,
    this.animePoster,
    required this.episodeId,
    required this.episodeName,
    required this.episodeNumber,
    required this.positionInSeconds,
    required this.durationInSeconds,
    required this.lastUpdated,
  });

  double get progress {
    if (durationInSeconds <= 0) return 0.0;
    final ratio = positionInSeconds / durationInSeconds;
    return ratio.clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'animeId': animeId,
      'animeTitle': animeTitle,
      'animePoster': animePoster,
      'episodeId': episodeId,
      'episodeName': episodeName,
      'episodeNumber': episodeNumber,
      'positionInSeconds': positionInSeconds,
      'durationInSeconds': durationInSeconds,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return WatchHistoryItem(
      animeId: json['animeId'] is int
          ? json['animeId']
          : int.parse(json['animeId'].toString()),
      animeTitle: json['animeTitle'] as String? ?? 'Anime',
      animePoster: json['animePoster'] as String?,
      episodeId: json['episodeId'].toString(),
      episodeName: json['episodeName'] as String? ?? 'Episode',
      episodeNumber: json['episodeNumber'].toString(),
      positionInSeconds: json['positionInSeconds'] as int? ?? 0,
      durationInSeconds: json['durationInSeconds'] as int? ?? 1,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }
}
