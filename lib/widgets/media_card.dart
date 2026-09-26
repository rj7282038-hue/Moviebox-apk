import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';
import '../screens/details_screen.dart';

class MediaCard extends StatelessWidget {
  final MediaItem media;
  final double width;
  final double height;

  const MediaCard({
    Key? key,
    required this.media,
    this.width = 130,
    this.height = 195,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(media: media),
          ),
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with Rating Badge
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    color: AppTheme.surfaceLight,
                    child: media.poster.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: media.poster,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                            errorWidget: (_, __, ___) => const Center(
                              child: Icon(Icons.movie, size: 40, color: AppTheme.textSecondary),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.movie, size: 40, color: AppTheme.textSecondary),
                          ),
                  ),
                  if (double.tryParse(media.imdbRating) != null &&
                      double.parse(media.imdbRating) > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: AppTheme.gold, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              media.imdbRating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Type badge (Series / Movie)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        media.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              media.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            // Year & Genres
            Text(
              media.year,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
