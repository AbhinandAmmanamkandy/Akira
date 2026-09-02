import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class ApiService {
  static const String _anilabBaseUrl = 'https://anilab2.amdapi.click/api';
  static const String _anidbBaseUrl = 'https://play.anidb.app/api';

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  /// Fetch Home page sections and featured anime
  Future<HomeData> getHome() async {
    final response = await http.get(
      Uri.parse('$_anilabBaseUrl/home'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return HomeData.fromJson(data);
    } else {
      throw Exception('Failed to load home data (${response.statusCode})');
    }
  }

  /// Fetch Latest anime releases
  Future<List<AnimePost>> getLatest({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_anilabBaseUrl/latest?page=$page'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List rawPosts = data['posts'] as List? ?? [];
      return rawPosts.map((e) => AnimePost.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load latest anime (${response.statusCode})');
    }
  }

  /// Fetch list of genres / categories
  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('$_anilabBaseUrl/categories'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List rawCats = data['categories'] as List? ?? [];
      return rawCats.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load categories (${response.statusCode})');
    }
  }

  /// Search anime by query
  Future<List<AnimePost>> searchAnime(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final encodedQuery = Uri.encodeComponent(query.trim());
    final response = await http.get(
      Uri.parse('$_anilabBaseUrl/search?query=$encodedQuery&page=$page'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List rawPosts = data['posts'] as List? ?? [];
      return rawPosts.map((e) => AnimePost.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to search anime (${response.statusCode})');
    }
  }

  /// Fetch full metadata details for a specific anime
  Future<AnimeDetail> getAnimeDetail(int id) async {
    final response = await http.get(
      Uri.parse('$_anilabBaseUrl/post?id=$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return AnimeDetail.fromJson(data);
    } else {
      throw Exception('Failed to load anime details (${response.statusCode})');
    }
  }

  /// Fetch episodes list for an anime ID
  Future<List<Episode>> getEpisodes(int animeId) async {
    final response = await http.get(
      Uri.parse('$_anidbBaseUrl/anime/$animeId/episodes'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List rawList = data['list'] as List? ?? [];
      return rawList.map((e) => Episode.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load episodes (${response.statusCode})');
    }
  }

  /// Fetch streaming servers for a given episode ID
  Future<List<EpisodeServer>> getEpisodeServers(String episodeId) async {
    final response = await http.get(
      Uri.parse('$_anidbBaseUrl/episode/$episodeId/servers'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List rawList = data['list'] as List? ?? [];
      return rawList.map((e) => EpisodeServer.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load servers (${response.statusCode})');
    }
  }

  /// Get video iframe stream URL for a given server ID (e.g. "70895/jpn")
  Future<String> getIframeUrl(String serverId) async {
    final response = await http.get(
      Uri.parse('$_anidbBaseUrl/episode/$serverId/iframe'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String link = data['link'] as String? ?? '';
      if (link.isEmpty) {
        throw Exception('Stream link is empty');
      }
      return link;
    } else {
      throw Exception('Failed to load iframe stream (${response.statusCode})');
    }
  }

  /// Extract direct .m3u8 or .mp4 video stream URL from embed HTML
  Future<String?> extractDirectStreamUrl(String iframeUrl) async {
    try {
      final response = await http.get(
        Uri.parse(iframeUrl),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final html = response.body;

        // Search for m3u8 or mp4 URL in HTML/JS source
        final RegExp m3u8Regex = RegExp(
          r'https?://[^\s"' "'" r'<>]+\.(?:m3u8|mp4)[^\s"' "'" r'<>]*',
          caseSensitive: false,
        );
        final match = m3u8Regex.firstMatch(html);
        if (match != null) {
          return match.group(0);
        }
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }
}
