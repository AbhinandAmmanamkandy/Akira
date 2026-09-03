import '../models/watch_history_item.dart';
import '../services/watch_history_service.dart';

class WatchHistoryRepository {
  final WatchHistoryService _service;

  WatchHistoryRepository({WatchHistoryService? service})
      : _service = service ?? WatchHistoryService();

  Future<List<WatchHistoryItem>> getHistory() => _service.getWatchHistory();

  Future<WatchHistoryItem?> getHistoryForEpisode(String episodeId) =>
      _service.getHistoryForEpisode(episodeId);

  Future<void> saveProgress(WatchHistoryItem item) => _service.saveWatchHistory(item);

  Future<void> removeProgress(String episodeId) => _service.removeItem(episodeId);
}
