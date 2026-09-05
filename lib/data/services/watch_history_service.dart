import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/watch_history_item.dart';

class WatchHistoryService {
  static const String _key = 'akira_watch_history';

  Future<List<WatchHistoryItem>> getWatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawStringList = prefs.getStringList(_key) ?? [];

    final items = <WatchHistoryItem>[];
    for (var raw in rawStringList) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(raw);
        items.add(WatchHistoryItem.fromJson(jsonMap));
      } catch (_) {}
    }

    items.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return items;
  }

  Future<WatchHistoryItem?> getHistoryForEpisode(String episodeId) async {
    final items = await getWatchHistory();
    for (var item in items) {
      if (item.episodeId == episodeId) return item;
    }
    return null;
  }

  Future<WatchHistoryItem?> getHistoryForAnime(int animeId) async {
    final items = await getWatchHistory();
    for (var item in items) {
      if (item.animeId == animeId) return item;
    }
    return null;
  }

  Future<void> saveWatchHistory(WatchHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getWatchHistory();

    final existingIndex = currentList.indexWhere(
      (e) => e.animeId == item.animeId,
    );

    if (existingIndex != -1) {
      final existingItem = currentList[existingIndex];

      double parseEpNum(String epNum) {
        return double.tryParse(epNum.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      }

      final newEpNum = parseEpNum(item.episodeNumber);
      final existingEpNum = parseEpNum(existingItem.episodeNumber);

      if (newEpNum < existingEpNum) {
        // Do not update the history if the new episode is a previous episode
        return;
      }

      currentList.removeAt(existingIndex);
    }

    currentList.insert(0, item);

    if (currentList.length > 30) {
      currentList.removeRange(30, currentList.length);
    }

    final rawStringList = currentList
        .map((e) => json.encode(e.toJson()))
        .toList();
    await prefs.setStringList(_key, rawStringList);
  }

  Future<void> removeItem(String episodeId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getWatchHistory();
    currentList.removeWhere((e) => e.episodeId == episodeId);
    final rawStringList = currentList
        .map((e) => json.encode(e.toJson()))
        .toList();
    await prefs.setStringList(_key, rawStringList);
  }
}
