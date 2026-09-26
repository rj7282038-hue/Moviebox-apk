class MediaItem {
  final String id;
  final String name;
  final String type; // 'movie' or 'series'
  final String poster;
  final String background;
  final String description;
  final String year;
  final String imdbRating;
  final List<String> genres;
  final String? runtime;
  final List<Episode> episodes;

  MediaItem({
    required this.id,
    required this.name,
    required this.type,
    required this.poster,
    required this.background,
    required this.description,
    required this.year,
    required this.imdbRating,
    required this.genres,
    this.runtime,
    this.episodes = const [],
  });

  factory MediaItem.fromCinemetaCatalog(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Title',
      type: json['type']?.toString() ?? 'movie',
      poster: json['poster']?.toString() ?? '',
      background: json['background']?.toString() ?? json['poster']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      year: json['year']?.toString() ?? (json['releaseInfo']?.toString() ?? 'N/A'),
      imdbRating: json['imdbRating']?.toString() ?? '0.0',
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      runtime: json['runtime']?.toString(),
    );
  }

  factory MediaItem.fromCinemetaMeta(Map<String, dynamic> json) {
    List<Episode> eps = [];
    if (json['videos'] != null && json['videos'] is List) {
      eps = (json['videos'] as List).map((v) => Episode.fromJson(v)).toList();
    }

    return MediaItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Title',
      type: json['type']?.toString() ?? 'movie',
      poster: json['poster']?.toString() ?? '',
      background: json['background']?.toString() ?? json['poster']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      year: json['year']?.toString() ?? (json['releaseInfo']?.toString() ?? 'N/A'),
      imdbRating: json['imdbRating']?.toString() ?? '0.0',
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      runtime: json['runtime']?.toString(),
      episodes: eps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'poster': poster,
      'background': background,
      'description': description,
      'year': year,
      'imdbRating': imdbRating,
      'genres': genres,
      'runtime': runtime,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'movie',
      poster: json['poster'] ?? '',
      background: json['background'] ?? '',
      description: json['description'] ?? '',
      year: json['year'] ?? '',
      imdbRating: json['imdbRating'] ?? '0.0',
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      runtime: json['runtime'],
    );
  }
}

class Episode {
  final String id;
  final String title;
  final int season;
  final int episode;
  final String? thumbnail;
  final String? released;
  final String? overview;

  Episode({
    required this.id,
    required this.title,
    required this.season,
    required this.episode,
    this.thumbnail,
    this.released,
    this.overview,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Episode ${json['episode']}',
      season: int.tryParse(json['season']?.toString() ?? '1') ?? 1,
      episode: int.tryParse(json['episode']?.toString() ?? '1') ?? 1,
      thumbnail: json['thumbnail']?.toString(),
      released: json['released']?.toString(),
      overview: json['overview']?.toString(),
    );
  }
}
