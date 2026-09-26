import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../services/cinemeta_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_banner.dart';
import '../widgets/media_card.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CinemetaService _cinemetaService = CinemetaService();

  List<MediaItem> _trendingMovies = [];
  List<MediaItem> _trendingSeries = [];
  MediaItem? _heroItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _cinemetaService.fetchTrendingMovies(),
        _cinemetaService.fetchTrendingSeries(),
      ]);

      setState(() {
        _trendingMovies = results[0];
        _trendingSeries = results[1];
        if (_trendingMovies.isNotEmpty) {
          _heroItem = _trendingMovies.first;
        }
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueWatching(StorageService storage) {
    final history = storage.getWatchHistory();
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Continue Watching'),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: history.length,
            itemBuilder: (context, idx) {
              final item = history[idx];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailsScreen(media: item.media)),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.media.background.isNotEmpty ? item.media.background : item.media.poster,
                              height: 100,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 100,
                                width: 200,
                                color: AppTheme.surfaceLight,
                                child: const Icon(Icons.play_circle, color: AppTheme.primary),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              value: item.progressPercentage,
                              backgroundColor: Colors.black54,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              minHeight: 4,
                            ),
                          ),
                          const Positioned(
                            bottom: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black87,
                              child: Icon(Icons.play_arrow, size: 16, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.media.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _loadCatalog,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              if (_heroItem != null)
                HeroBanner(
                  media: _heroItem!,
                  isFavorite: storage.isFavorite(_heroItem!.id),
                  onToggleFavorite: () => storage.toggleFavorite(_heroItem!),
                  onPlay: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailsScreen(media: _heroItem!)),
                    );
                  },
                ),

              const SizedBox(height: 8),

              // Continue Watching
              _buildContinueWatching(storage),

              // Trending Movies Row
              _buildSectionHeader('Trending Movies'),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _trendingMovies.length,
                  itemBuilder: (context, idx) => MediaCard(media: _trendingMovies[idx]),
                ),
              ),

              // Popular TV Shows Row
              _buildSectionHeader('Popular TV Shows'),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _trendingSeries.length,
                  itemBuilder: (context, idx) => MediaCard(media: _trendingSeries[idx]),
                ),
              ),

              // Anime & Asian Dramas (inspired by MovieBox-TUI Dramachi provider)
              _buildSectionHeader('Top Rated & Classics'),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _trendingMovies.reversed.toList().length,
                  itemBuilder: (context, idx) => MediaCard(
                    media: _trendingMovies.reversed.toList()[idx],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
