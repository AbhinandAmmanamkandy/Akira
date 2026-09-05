import '../models/anime_detail.dart';
import '../models/anime_post.dart';
import '../models/category.dart';
import '../models/episode.dart';
import '../models/home_data.dart';
import '../services/api_service.dart';

class AnimeRepository {
  final ApiService _apiService;

  AnimeRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<HomeData?> getCachedHome() => _apiService.getCachedHome();

  Future<List<AnimePost>> getCachedLatest() => _apiService.getCachedLatest();

  Future<HomeData> fetchHome() => _apiService.getHome();

  Future<List<AnimePost>> fetchLatest({int page = 1}) =>
      _apiService.getLatest(page: page);

  Future<List<Category>> fetchCategories() => _apiService.getCategories();

  Future<List<AnimePost>> searchAnime(String query, {int page = 1}) =>
      _apiService.searchAnime(query, page: page);

  Future<AnimeDetail> fetchAnimeDetail(int id) =>
      _apiService.getAnimeDetail(id);

  Future<List<Episode>> fetchEpisodes(int animeId) =>
      _apiService.getEpisodes(animeId);

  Future<List<EpisodeServer>> fetchEpisodeServers(String episodeId) =>
      _apiService.getEpisodeServers(episodeId);

  Future<String> fetchIframeUrl(String serverId) =>
      _apiService.getIframeUrl(serverId);

  Future<String?> extractDirectStreamUrl(String iframeUrl) =>
      _apiService.extractDirectStreamUrl(iframeUrl);
}
