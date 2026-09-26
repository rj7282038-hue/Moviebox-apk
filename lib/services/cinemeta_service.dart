import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class CinemetaService {
  static const String baseUrl = 'https://v3-cinemeta.strem.io';

  /// Fetches Top/Trending Movies
  Future<List<MediaItem>> fetchTrendingMovies({int skip = 0}) async {
    try {
      final url = Uri.parse('$baseUrl/catalog/movie/top.json?skip=$skip');
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['metas'] != null && data['metas'] is List) {
          return (data['metas'] as List)
              .map((item) => MediaItem.fromCinemetaCatalog(item))
              .toList();
        }
      }
    } catch (e) {
      // Fallback or log error
    }
    return [];
  }

  /// Fetches Top/Trending TV Shows & Series
  Future<List<MediaItem>> fetchTrendingSeries({int skip = 0}) async {
    try {
      final url = Uri.parse('$baseUrl/catalog/series/top.json?skip=$skip');
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['metas'] != null && data['metas'] is List) {
          return (data['metas'] as List)
              .map((item) => MediaItem.fromCinemetaCatalog(item))
              .toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return [];
  }

  /// Search movies or series by query
  Future<List<MediaItem>> search(String query, {String type = 'movie'}) async {
    if (query.trim().isEmpty) return [];
    try {
      final encoded = Uri.encodeComponent(query.trim());
      final url = Uri.parse('$baseUrl/catalog/$type/top/search=$encoded.json');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['metas'] != null && data['metas'] is List) {
          return (data['metas'] as List)
              .map((item) => MediaItem.fromCinemetaCatalog(item))
              .toList();
        }
      }
    } catch (e) {
      // Fallback
    }
    return [];
  }

  /// Fetches comprehensive details including episodes for series
  Future<MediaItem?> fetchDetails(String id, String type) async {
    try {
      final url = Uri.parse('$baseUrl/meta/$type/$id.json');
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meta'] != null) {
          return MediaItem.fromCinemetaMeta(data['meta']);
        }
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }
}
