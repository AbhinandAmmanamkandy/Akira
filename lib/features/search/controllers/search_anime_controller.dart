import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/anime_post.dart';
import '../../../data/repositories/anime_repository.dart';

enum SearchState { idle, searching, success, error }

class SearchAnimeController extends ChangeNotifier {
  final AnimeRepository _repository;
  Timer? _debounce;

  SearchAnimeController({AnimeRepository? repository})
      : _repository = repository ?? AnimeRepository();

  SearchState _state = SearchState.idle;
  List<AnimePost> _searchResults = [];
  String _errorMessage = '';
  bool _hasSearched = false;

  SearchState get state => _state;
  List<AnimePost> get searchResults => _searchResults;
  String get errorMessage => _errorMessage;
  bool get hasSearched => _hasSearched;

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: AppConstants.searchDebounceMs), () {
      if (query.trim().isNotEmpty) {
        performSearch(query.trim());
      } else {
        clearSearch();
      }
    });
  }

  Future<void> performSearch(String query) async {
    _state = SearchState.searching;
    _hasSearched = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _searchResults = await _repository.searchAnime(query);
      _state = SearchState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = SearchState.error;
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _hasSearched = false;
    _state = SearchState.idle;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
