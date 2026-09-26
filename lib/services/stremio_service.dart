import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stream_source.dart';
import '../models/stremio_addon.dart';

class StremioService {
  /// Default pre-configured addons inspired by MovieBox-TUI
  static final List<StremioAddon> defaultAddons = [
    StremioAddon(
      id: 'torrentio',
      name: 'Torrentio Streams',
      description: 'Multi-resolution high quality movie and series streams',
      manifestUrl: 'https://torrentio.strem.fun/manifest.json',
      isEnabled: true,
      isProtected: true,
    ),
    StremioAddon(
      id: 'cyberflix',
      name: 'CyberFlix Catalog',
      description: 'Extended catalog and metadata provider',
      manifestUrl: 'https://cyberflix.kamyroll.net/manifest.json',
      isEnabled: true,
      isProtected: false,
    ),
  ];

  /// Concurrent multi-addon stream resolution (MovieBox-TUI feature)
  Future<List<StreamSource>> resolveStreams({
    required String imdbId,
    required String type, // 'movie' or 'series'
    int? season,
    int? episode,
    required List<StremioAddon> addons,
  }) async {
    final List<StreamSource> allStreams = [];

    // Format target ID (e.g. tt0944947:1:1 for series episode)
    final targetId = (type == 'series' && season != null && episode != null)
        ? '$imdbId:$season:$episode'
        : imdbId;

    // Filter only enabled addons
    final activeAddons = addons.where((a) => a.isEnabled).toList();

    // Query all addons concurrently
    final futures = activeAddons.map((addon) => _fetchAddonStreams(addon, type, targetId));
    final results = await Future.wait(futures);

    for (final streamList in results) {
      allStreams.addAll(streamList);
    }

    // Also append direct embed resolvers (MovieBox native web streaming fallback)
    allStreams.addAll(_getDirectEmbedSources(imdbId, type, season, episode));

    // Sort streams: 4K first, then 1080p, 720p, 480p, and then by seed count
    allStreams.sort((a, b) {
      final rankA = _qualityRank(a.quality);
      final rankB = _qualityRank(b.quality);
      if (rankA != rankB) {
        return rankB.compareTo(rankA);
      }
      return (b.seeds ?? 0).compareTo(a.seeds ?? 0);
    });

    return allStreams;
  }

  int _qualityRank(String q) {
    switch (q.toUpperCase()) {
      case '4K':
        return 4;
      case '1080P':
        return 3;
      case '720P':
        return 2;
      case '480P':
        return 1;
      default:
        return 0;
    }
  }

  Future<List<StreamSource>> _fetchAddonStreams(
    StremioAddon addon,
    String type,
    String targetId,
  ) async {
    try {
      // Manifest URL e.g. https://torrentio.strem.fun/manifest.json -> root base
      final base = addon.manifestUrl.replaceAll('/manifest.json', '');
      final streamUrl = Uri.parse('$base/stream/$type/$targetId.json');

      final response = await http.get(streamUrl).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['streams'] != null && data['streams'] is List) {
          return (data['streams'] as List)
              .map((s) => StreamSource.fromStremioStream(s, addon.name))
              .where((s) => s.url.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {
      // Addon timeout or offline
    }
    return [];
  }

  /// Direct fallback streaming servers
  List<StreamSource> _getDirectEmbedSources(String imdbId, String type, int? season, int? episode) {
    final List<StreamSource> embeds = [];
    if (type == 'movie') {
      embeds.add(StreamSource(
        title: 'VidSrc Fast Stream [1080p Web-Direct]',
        providerName: 'VidSrc Direct',
        url: 'https://vidsrc.to/embed/movie/$imdbId',
        quality: '1080p',
        size: 'Multi-Bitrate',
      ));
      embeds.add(StreamSource(
        title: 'SuperEmbed Server 1 [Auto Quality]',
        providerName: 'SuperEmbed',
        url: 'https://multiembed.mov/?video_id=$imdbId',
        quality: '1080p',
      ));
    } else {
      final s = season ?? 1;
      final e = episode ?? 1;
      embeds.add(StreamSource(
        title: 'VidSrc Episode Stream [S$s E$e 1080p]',
        providerName: 'VidSrc Direct',
        url: 'https://vidsrc.to/embed/tv/$imdbId/$s/$e',
        quality: '1080p',
      ));
      embeds.add(StreamSource(
        title: 'SuperEmbed Server TV [S$s E$e]',
        providerName: 'SuperEmbed',
        url: 'https://multiembed.mov/?video_id=$imdbId&s=$s&e=$e',
        quality: '720p',
      ));
    }
    return embeds;
  }
}
