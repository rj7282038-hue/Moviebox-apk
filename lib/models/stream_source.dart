class StreamSource {
  final String title;
  final String providerName;
  final String url;
  final String quality; // 4K, 1080p, 720p, 480p, Auto
  final String? size;
  final int? seeds;
  final bool isHls;
  final Map<String, String>? headers;

  StreamSource({
    required this.title,
    required this.providerName,
    required this.url,
    required this.quality,
    this.size,
    this.seeds,
    this.isHls = false,
    this.headers,
  });

  factory StreamSource.fromStremioStream(Map<String, dynamic> json, String addonName) {
    final title = json['title']?.toString() ?? json['name']?.toString() ?? 'Stream';
    final streamUrl = json['url']?.toString() ?? '';
    
    // Extract resolution heuristics from title or name
    String detectedQuality = '1080p';
    final lowerTitle = (title + (json['name']?.toString() ?? '')).toLowerCase();
    if (lowerTitle.contains('4k') || lowerTitle.contains('2160p') || lowerTitle.contains('uhd')) {
      detectedQuality = '4K';
    } else if (lowerTitle.contains('1080p') || lowerTitle.contains('fhd')) {
      detectedQuality = '1080p';
    } else if (lowerTitle.contains('720p') || lowerTitle.contains('hd')) {
      detectedQuality = '720p';
    } else if (lowerTitle.contains('480p') || lowerTitle.contains('sd')) {
      detectedQuality = '480p';
    }

    // Extract size heuristic e.g. "💾 2.4 GB" or "1.5GB"
    String? detectedSize;
    final sizeRegex = RegExp(r'(\d+(\.\d+)?\s*(GB|MB))', caseSensitive: false);
    final sizeMatch = sizeRegex.firstMatch(title);
    if (sizeMatch != null) {
      detectedSize = sizeMatch.group(0);
    }

    // Extract seeds heuristic e.g. "👤 45"
    int? detectedSeeds;
    final seedsRegex = RegExp(r'👤\s*(\d+)');
    final seedsMatch = seedsRegex.firstMatch(title);
    if (seedsMatch != null) {
      detectedSeeds = int.tryParse(seedsMatch.group(1) ?? '');
    }

    Map<String, String>? headers;
    if (json['behaviorHints'] != null && json['behaviorHints']['proxyHeaders'] != null) {
      final proxyReq = json['behaviorHints']['proxyHeaders']['request'];
      if (proxyReq is Map) {
        headers = proxyReq.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    }

    return StreamSource(
      title: title,
      providerName: addonName,
      url: streamUrl,
      quality: detectedQuality,
      size: detectedSize,
      seeds: detectedSeeds,
      isHls: streamUrl.endsWith('.m3u8') || (json['behaviorHints']?['notWebReady'] == true),
      headers: headers,
    );
  }
}
