class PlayerConfig {
  final String? playerName;
  final String? playerDesc;
  final String? packageName;
  final String? activityName;
  final String? downloadUrl;
  final String? playerIcon;

  const PlayerConfig({
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
