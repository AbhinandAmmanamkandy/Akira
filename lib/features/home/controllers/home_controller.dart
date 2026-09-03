import 'package:flutter/material.dart';
import '../../../data/models/home_data.dart';
import '../../../data/repositories/anime_repository.dart';

enum HomeState { initial, loading, success, error }

class HomeController extends ChangeNotifier {
  final AnimeRepository _repository;

  HomeController({AnimeRepository? repository})
      : _repository = repository ?? AnimeRepository();

  HomeState _state = HomeState.initial;
  HomeData? _homeData;
  String _errorMessage = '';

  HomeState get state => _state;
  HomeData? get homeData => _homeData;
  String get errorMessage => _errorMessage;

  Future<void> loadHomeData() async {
    _state = HomeState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _homeData = await _repository.fetchHome();
      _state = HomeState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = HomeState.error;
    }
    notifyListeners();
  }
}
