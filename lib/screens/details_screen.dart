import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../services/cinemeta_service.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stream_selector_modal.dart';

class DetailsScreen extends StatefulWidget {
  final MediaItem media;

  const DetailsScreen({Key? key, required this.media}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final CinemetaService _cinemetaService = CinemetaService();
  MediaItem? _fullMedia;
  bool _isLoading = true;
  int _selectedSeason = 1;

  @override
  void initState() {
    super.initState();
    _loadFullDetails();
  }

  Future<void> _loadFullDetails() async {
    final item = await _cinemetaService.fetchDetails(widget.media.id, widget.media.type);
    setState(() {
      _fullMedia = item ?? widget.media;
      _isLoading = false;
    });
  }

  void _openStreamSelector({int? season, int? episode}) {
    final storage = Provider.of<StorageService>(context, listen: false);
    final download = Provider.of<DownloadService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StreamSelectorModal(
        media: _fullMedia ?? widget.media,
        season: season,
        episode: episode,
        storageService: storage,
        downloadService: download,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = _fullMedia ?? widget.media;
    final storage = Provider.of<StorageService>(context);
    final isFav = storage.isFavorite(media.id);

    // Group episodes by season if series
    final seasons = <int, List<Episode>>{};
    if (media.type == 'series' && media.episodes.isNotEmpty) {
      for (final ep in media.episodes) {
        seasons.putIfAbsent(ep.season, () => []).add(ep);
      }
      if (!seasons.containsKey(_selectedSeason) && seasons.isNotEmpty) {
        _selectedSeason = seasons.keys.first;
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Backdrop App Bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (media.background.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: media.background,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceLight),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          AppTheme.background,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.bookmark : Icons.bookmark_border,
                  color: isFav ? AppTheme.primary : Colors.white,
                ),
                onPressed: () => storage.toggleFavorite(media),
              ),
            ],
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    media.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata Badges (Rating, Year, Type, Runtime)
                  Row(
                    children: [
                      if (double.tryParse(media.imdbRating) != null &&
                          double.parse(media.imdbRating) > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: AppTheme.gold, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                media.imdbRating,
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(media.year, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          media.type.toUpperCase(),
                          style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (media.runtime != null) ...[
                        const SizedBox(width: 10),
                        Text(media.runtime!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Genres
                  if (media.genres.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: media.genres.map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(g, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),

                  // Play Button for Movies
                  if (media.type == 'movie')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _openStreamSelector(),
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: const Text(
                          'Stream Movie',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Overview / Synopsis
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    media.description.isNotEmpty ? media.description : 'No overview available.',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TV Series Episodes Section
                  if (media.type == 'series') ...[
                    const Text(
                      'Seasons & Episodes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),

                    // Season Chips
                    if (seasons.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: seasons.keys.map((s) {
                            final isSel = s == _selectedSeason;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('Season $s'),
                                selected: isSel,
                                selectedColor: AppTheme.primary,
                                backgroundColor: AppTheme.surfaceLight,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedSeason = s);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Episode List
                    if (seasons.containsKey(_selectedSeason))
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: seasons[_selectedSeason]!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final ep = seasons[_selectedSeason]![idx];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primary.withOpacity(0.2),
                                child: Text(
                                  '${ep.episode}',
                                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                ep.title,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                              ),
                              subtitle: ep.overview != null
                                  ? Text(
                                      ep.overview!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                    )
                                  : null,
                              trailing: IconButton(
                                icon: const Icon(Icons.play_circle_fill, color: AppTheme.primary, size: 28),
                                onPressed: () => _openStreamSelector(
                                  season: ep.season,
                                  episode: ep.episode,
                                ),
                              ),
                              onTap: () => _openStreamSelector(
                                season: ep.season,
                                episode: ep.episode,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
