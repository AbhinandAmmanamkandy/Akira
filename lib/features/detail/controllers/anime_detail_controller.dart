import 'package:flutter/material.dart';
import '../../../data/models/anime_detail.dart';
import '../../../data/models/episode.dart';
import '../../../data/models/watch_history_item.dart';
import '../../../data/repositories/anime_repository.dart';
import '../../../data/repositories/watch_history_repository.dart';

class AnimeDetailController extends ChangeNotifier {
  final AnimeRepository _repository;
  final WatchHistoryRepository _historyRepository;
  final int animeId;

  AnimeDetailController({
    required this.animeId,
    AnimeRepository? repository,
    WatchHistoryRepository? historyRepository,
  })  : _repository = repository ?? AnimeRepository(),
        _historyRepository = historyRepository ?? WatchHistoryRepository();

  AnimeDetail? _detail;
  List<Episode> _episodes = [];
  List<Episode> _filteredEpisodes = [];
  WatchHistoryItem? _lastWatchHistory;
  Episode? _resumeEpisode;

  bool _isLoadingDetail = true;
  bool _isLoadingEpisodes = true;
  String? _errorMessage;

  AnimeDetail? get detail => _detail;
  List<Episode> get episodes => _episodes;
  List<Episode> get filteredEpisodes => _filteredEpisodes;
  WatchHistoryItem? get lastWatchHistory => _lastWatchHistory;
  Episode? get resumeEpisode => _resumeEpisode;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingEpisodes => _isLoadingEpisodes;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoadingDetail = true;
    _isLoadingEpisodes = true;
    _errorMessage = null;
    notifyListeners();

    _fetchDetail();
    _fetchEpisodesAndHistory();
  }

  Future<void> _fetchDetail() async {
    try {
      _detail = await _repository.fetchAnimeDetail(animeId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoadingDetail = false;
    notifyListeners();
  }

  Future<void> _fetchEpisodesAndHistory() async {
    try {
      _episodes = await _repository.fetchEpisodes(animeId);
      _filteredEpisodes = _episodes;

      _lastWatchHistory = await _historyRepository.getHistoryForAnime(animeId);
      if (_lastWatchHistory != null && _episodes.isNotEmpty) {
        _resumeEpisode = _episodes.firstWhere(
          (ep) => ep.id == _lastWatchHistory!.episodeId,
          orElse: () => _episodes.first,
        );
      } else if (_episodes.isNotEmpty) {
        _resumeEpisode = _episodes.first;
      }
    } catch (_) {}
    _isLoadingEpisodes = false;
    notifyListeners();
  }

  void filterEpisodes(String query) {
    if (query.trim().isEmpty) {
      _filteredEpisodes = _episodes;
    } else {
      final q = query.toLowerCase();
      _filteredEpisodes = _episodes.where((ep) {
        return ep.name.toLowerCase().contains(q) ||
            ep.number.toLowerCase().contains(q);
      }).toList();
    }
    notifyListeners();
  }
}
