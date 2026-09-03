import 'package:flutter/material.dart';
import '../../../data/models/anime_post.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/anime_repository.dart';

enum ExploreState { initial, loading, success, error }

class ExploreController extends ChangeNotifier {
  final AnimeRepository _repository;

  ExploreController({AnimeRepository? repository})
      : _repository = repository ?? AnimeRepository();

  List<Category> _categories = [];
  List<AnimePost> _latestPosts = [];
  int _currentPage = 1;

  bool _isLoadingCategories = true;
  bool _isLoadingLatest = true;
  bool _isLoadingMore = false;
  int? _selectedCategoryId;
  String _errorMessage = '';

  List<Category> get categories => _categories;
  List<AnimePost> get latestPosts => _latestPosts;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingLatest => _isLoadingLatest;
  bool get isLoadingMore => _isLoadingMore;
  int? get selectedCategoryId => _selectedCategoryId;
  String get errorMessage => _errorMessage;

  Future<void> init() async {
    await Future.wait([
      fetchCategories(),
      fetchLatestPosts(),
    ]);
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _categories = await _repository.fetchCategories();
    } catch (_) {}
    _isLoadingCategories = false;
    notifyListeners();
  }

  Future<void> fetchLatestPosts() async {
    _isLoadingLatest = true;
    _currentPage = 1;
    _errorMessage = '';
    notifyListeners();

    try {
      _latestPosts = await _repository.fetchLatest(page: 1);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoadingLatest = false;
    notifyListeners();
  }

  Future<void> loadMorePosts() async {
    if (_isLoadingMore || _isLoadingLatest) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newPosts = await _repository.fetchLatest(page: nextPage);
      _currentPage = nextPage;
      _latestPosts.addAll(newPosts);
    } catch (_) {}
    _isLoadingMore = false;
    notifyListeners();
  }

  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
}
