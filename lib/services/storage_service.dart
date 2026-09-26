import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';
import '../models/stremio_addon.dart';
import 'stremio_service.dart';

class WatchHistoryItem {
  final MediaItem media;
  final int positionSeconds;
  final int durationSeconds;
  final DateTime updatedAt;
  final int? season;
  final int? episode;

  WatchHistoryItem({
    required this.media,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.updatedAt,
    this.season,
    this.episode,
  });

  double get progressPercentage => durationSeconds > 0
      ? (positionSeconds / durationSeconds).clamp(0.0, 1.0)
      : 0.0;

  Map<String, dynamic> toJson() => {
    'media': media.toJson(),
    'positionSeconds': positionSeconds,
    'durationSeconds': durationSeconds,
    'updatedAt': updatedAt.toIso8601String(),
    'season': season,
    'episode': episode,
  };

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) => WatchHistoryItem(
    media: MediaItem.fromJson(json['media']),
    positionSeconds: json['positionSeconds'] ?? 0,
    durationSeconds: json['durationSeconds'] ?? 0,
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    season: json['season'],
    episode: json['episode'],
  );
}

class StorageService {
  static const String _keyHistory = 'moviebox_history';
  static const String _keyFavorites = 'moviebox_favorites';
  static const String _keyAddons = 'moviebox_addons';
  static const String _keyCustomM3u = 'moviebox_custom_m3u';
  static const String _keyDefaultQuality = 'moviebox_pref_quality';
  static const String _keyUseExternalPlayer = 'moviebox_external_player';

  final SharedPreferences prefs;

  StorageService(this.prefs);

  static Future<StorageService> init() async {
    final sp = await SharedPreferences.getInstance();
    return StorageService(sp);
  }

  // --- Watch History ---
  List<WatchHistoryItem> getWatchHistory() {
    final list = prefs.getStringList(_keyHistory) ?? [];
    return list.map((item) => WatchHistoryItem.fromJson(json.decode(item))).toList();
  }

  Future<void> saveWatchProgress({
    required MediaItem media,
    required int positionSeconds,
    required int durationSeconds,
    int? season,
    int? episode,
  }) async {
    final history = getWatchHistory();
    history.removeWhere((item) => item.media.id == media.id);
    history.insert(
      0,
      WatchHistoryItem(
        media: media,
        positionSeconds: positionSeconds,
        durationSeconds: durationSeconds,
        updatedAt: DateTime.now(),
        season: season,
        episode: episode,
      ),
    );

    // Keep up to 30 items
    if (history.length > 30) history.removeLast();

    final encoded = history.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_keyHistory, encoded);
  }

  Future<void> clearHistory() async {
    await prefs.remove(_keyHistory);
  }

  // --- Favorites / Bookmarks ---
  List<MediaItem> getFavorites() {
    final list = prefs.getStringList(_keyFavorites) ?? [];
    return list.map((item) => MediaItem.fromJson(json.decode(item))).toList();
  }

  bool isFavorite(String id) {
    return getFavorites().any((m) => m.id == id);
  }

  Future<void> toggleFavorite(MediaItem media) async {
    final favorites = getFavorites();
    final index = favorites.indexWhere((m) => m.id == media.id);
    if (index != -1) {
      favorites.removeAt(index);
    } else {
      favorites.insert(0, media);
    }
    final encoded = favorites.map((m) => json.encode(m.toJson())).toList();
    await prefs.setStringList(_keyFavorites, encoded);
  }

  // --- Stremio Addons Management ---
  List<StremioAddon> getAddons() {
    final list = prefs.getStringList(_keyAddons);
    if (list == null || list.isEmpty) {
      return StremioService.defaultAddons;
    }
    return list.map((item) => StremioAddon.fromJson(json.decode(item))).toList();
  }

  Future<void> saveAddons(List<StremioAddon> addons) async {
    final encoded = addons.map((a) => json.encode(a.toJson())).toList();
    await prefs.setStringList(_keyAddons, encoded);
  }

  Future<void> toggleAddon(String id, bool enabled) async {
    final addons = getAddons();
    for (final a in addons) {
      if (a.id == id) {
        a.isEnabled = enabled;
      }
    }
    await saveAddons(addons);
  }

  Future<void> addCustomAddon(StremioAddon addon) async {
    final addons = getAddons();
    addons.removeWhere((a) => a.manifestUrl == addon.manifestUrl);
    addons.add(addon);
    await saveAddons(addons);
  }

  // --- Preferences ---
  String getPreferredQuality() => prefs.getString(_keyDefaultQuality) ?? '1080p';
  Future<void> setPreferredQuality(String q) => prefs.setString(_keyDefaultQuality, q);

  bool getUseExternalPlayer() => prefs.getBool(_keyUseExternalPlayer) ?? false;
  Future<void> setUseExternalPlayer(bool val) => prefs.setBool(_keyUseExternalPlayer, val);

  String? getCustomM3uUrl() => prefs.getString(_keyCustomM3u);
  Future<void> setCustomM3uUrl(String url) => prefs.setString(_keyCustomM3u, url);
}
