import 'package:flutter/material.dart';
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
  List<WatchHistoryItem> _watchHistory = [];
  String _errorMessage = '';

  HomeState get state => _state;
  HomeData? get homeData => _homeData;
  List<WatchHistoryItem> get watchHistory => _watchHistory;
  String get errorMessage => _errorMessage;

  Future<void> loadHomeData() async {
    _state = HomeState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchHome(),
        _historyRepository.getHistory(),
      ]);
      _homeData = results[0] as HomeData;
      _watchHistory = results[1] as List<WatchHistoryItem>;
      _state = HomeState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = HomeState.error;
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
