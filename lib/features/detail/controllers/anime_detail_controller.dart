import 'package:flutter/material.dart';
import '../../../data/models/anime_detail.dart';
import '../../../data/models/episode.dart';
import '../../../data/repositories/anime_repository.dart';

class AnimeDetailController extends ChangeNotifier {
  final AnimeRepository _repository;
  final int animeId;

  AnimeDetailController({
    required this.animeId,
    AnimeRepository? repository,
  }) : _repository = repository ?? AnimeRepository();

  AnimeDetail? _detail;
  List<Episode> _episodes = [];
  List<Episode> _filteredEpisodes = [];

  bool _isLoadingDetail = true;
  bool _isLoadingEpisodes = true;
  String? _errorMessage;

  AnimeDetail? get detail => _detail;
  List<Episode> get episodes => _episodes;
  List<Episode> get filteredEpisodes => _filteredEpisodes;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingEpisodes => _isLoadingEpisodes;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoadingDetail = true;
    _isLoadingEpisodes = true;
    _errorMessage = null;
    notifyListeners();

    _fetchDetail();
    _fetchEpisodes();
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

  Future<void> _fetchEpisodes() async {
    try {
      _episodes = await _repository.fetchEpisodes(animeId);
      _filteredEpisodes = _episodes;
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
