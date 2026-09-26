import 'package:http/http.dart' as http;
import '../models/iptv_channel.dart';

class IptvService {
  /// Default free curated IPTV playlists
  static const String defaultPlaylistUrl = 'https://iptv-org.github.io/iptv/index.m3u';

  /// Parse M3U / M3U8 playlist from URL or text
  Future<List<IptvChannel>> loadPlaylist([String? playlistUrl]) async {
    final url = playlistUrl ?? defaultPlaylistUrl;
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return parseM3u(response.body);
      }
    } catch (_) {
      // Return fallback curated live channels if offline or timeout
    }
    return getCuratedChannels();
  }

  /// Parses M3U format with EXTINF metadata
  List<IptvChannel> parseM3u(String content) {
    final List<IptvChannel> channels = [];
    final lines = content.split('\n');

    String currentName = '';
    String currentLogo = '';
    String currentGroup = 'General';
    String? currentTvgId;

    final logoRegex = RegExp(r'tvg-logo="([^"]*)"');
    final groupRegex = RegExp(r'group-title="([^"]*)"');
    final tvgIdRegex = RegExp(r'tvg-id="([^"]*)"');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF:')) {
        // Extract tvg-logo
        final logoMatch = logoRegex.firstMatch(line);
        currentLogo = logoMatch?.group(1) ?? '';

        // Extract group-title
        final groupMatch = groupRegex.firstMatch(line);
        currentGroup = groupMatch?.group(1) ?? 'General';

        // Extract tvg-id
        final tvgIdMatch = tvgIdRegex.firstMatch(line);
        currentTvgId = tvgIdMatch?.group(1);

        // Extract channel name (after last comma)
        final commaIdx = line.lastIndexOf(',');
        if (commaIdx != -1) {
          currentName = line.substring(commaIdx + 1).trim();
        } else {
          currentName = 'Channel';
        }
      } else if (!line.startsWith('#') && (line.startsWith('http://') || line.startsWith('https://'))) {
        channels.add(IptvChannel(
          name: currentName.isEmpty ? 'Live Channel' : currentName,
          logo: currentLogo,
          group: currentGroup.isEmpty ? 'General' : currentGroup,
          url: line,
          tvgId: currentTvgId,
        ));
        // Reset for next channel
        currentName = '';
        currentLogo = '';
        currentGroup = 'General';
        currentTvgId = null;
      }
    }

    return channels;
  }

  /// Fallback curated verified live channels
  List<IptvChannel> getCuratedChannels() {
    return [
      IptvChannel(
        name: 'Red Bull TV HD',
        logo: 'https://images.redbull.com/image/upload/c_crop,x_0,y_0,h_1080,w_1920/c_fill,w_360/q_auto:low,f_auto/v1/editorial/red-bull-tv-logo.png',
        group: 'Sports',
        url: 'https://rbmn-live.akamaized.net/hls/live/590964/BoRB-AT/master.m3u8',
      ),
      IptvChannel(
        name: 'Euronews English',
        logo: 'https://upload.wikimedia.org/wikipedia/commons/4/47/Euronews_2016_logo.svg',
        group: 'News',
        url: 'https://euronews-euronews-world-1-au.samsung.wurl.com/manifest/playlist.m3u8',
      ),
      IptvChannel(
        name: 'Bloomberg TV',
        logo: 'https://upload.wikimedia.org/wikipedia/commons/e/e5/Bloomberg_Television_logo.svg',
        group: 'News',
        url: 'https://liveproduseast.global.ssl.fastly.net/us/Channel-us-live/manifest.m3u8',
      ),
      IptvChannel(
        name: 'NASA TV HD',
        logo: 'https://upload.wikimedia.org/wikipedia/commons/e/e5/NASA_logo.svg',
        group: 'Science',
        url: 'https://ntv1.akamaized.net/hls/live/2014075/NASA-NTV1-HLS/master.m3u8',
      ),
      IptvChannel(
        name: 'DW English HD',
        logo: 'https://upload.wikimedia.org/wikipedia/commons/7/75/Deutsche_Welle_logo.svg',
        group: 'News',
        url: 'https://dwamdstream102.akamaized.net/hls/live/2015525/dwstream102/index.m3u8',
      ),
      IptvChannel(
        name: 'Cinema World',
        logo: 'https://cdn-icons-png.flaticon.com/512/3163/3163478.png',
        group: 'Movies',
        url: 'https://d2e1asnsl7br7b.cloudfront.net/7782/master.m3u8',
      ),
    ];
  }
}
