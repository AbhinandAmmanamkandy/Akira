import 'package:flutter/material.dart';
import '../../../data/models/anime_post.dart';
import '../../../data/models/home_data.dart';
import '../../../data/models/watch_history_item.dart';
import '../../../data/repositories/anime_repository.dart';
import '../../../data/repositories/watch_history_repository.dart';

enum HomeState { initial, loading, success, error }

class HomeController extends ChangeNotifier {
  final AnimeRepository _repository;
  final WatchHistoryRepository _historyRepository;

  HomeController({
    AnimeRepository? repository,
    WatchHistoryRepository? historyRepository,
  })  : _repository = repository ?? AnimeRepository(),
        _historyRepository = historyRepository ?? WatchHistoryRepository();

  HomeState _state = HomeState.initial;
  HomeData? _homeData;
  List<AnimePost> _latestPosts = [];
  List<WatchHistoryItem> _watchHistory = [];
  String _errorMessage = '';

  HomeState get state => _state;
  HomeData? get homeData => _homeData;
  List<AnimePost> get latestPosts => _latestPosts;
  List<WatchHistoryItem> get watchHistory => _watchHistory;
  String get errorMessage => _errorMessage;

  Future<void> loadHomeData() async {
    _errorMessage = '';

    // 1. Instantly load cached home data, latest posts, and watch history
    final cachedHome = await _repository.getCachedHome();
    final cachedLatest = await _repository.getCachedLatest();
    final history = await _historyRepository.getHistory();
    _watchHistory = history;
    _latestPosts = cachedLatest;

    if (cachedHome != null) {
      _homeData = cachedHome;
      _state = HomeState.success;
      notifyListeners();
    } else {
      _state = HomeState.loading;
      notifyListeners();
    }

    // 2. Fetch fresh home data & latest posts in the background (stale-while-revalidate)
    try {
      final results = await Future.wait([
        _repository.fetchHome(),
        _repository.fetchLatest(),
      ]);
      _homeData = results[0] as HomeData;
      _latestPosts = results[1] as List<AnimePost>;
      _state = HomeState.success;
    } catch (e) {
      if (_homeData == null) {
        _errorMessage = e.toString();
        _state = HomeState.error;
      }
    }
    notifyListeners();
  }

  Future<void> refreshWatchHistory() async {
    try {
      _watchHistory = await _historyRepository.getHistory();
      notifyListeners();
    } catch (_) {}
  }
}
