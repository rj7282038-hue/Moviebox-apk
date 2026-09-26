import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';
import '../screens/details_screen.dart';

class HeroBanner extends StatelessWidget {
  final MediaItem media;
  final VoidCallback onPlay;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const HeroBanner({
    Key? key,
    required this.media,
    required this.onPlay,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Backdrop Image
        SizedBox(
          height: screenHeight * 0.45,
          width: double.infinity,
          child: media.background.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: media.background,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: AppTheme.surfaceLight),
                )
              : Container(color: AppTheme.surfaceLight),
        ),
        // Gradient overlay
        Container(
          height: screenHeight * 0.45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppTheme.background.withOpacity(0.5),
                AppTheme.background,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        // Title and actions
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                media.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              if (media.genres.isNotEmpty)
                Text(
                  media.genres.take(3).join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailsScreen(media: media)),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text(
                      'Watch Now',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // My List button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.check : Icons.add,
                      size: 20,
                      color: isFavorite ? AppTheme.primary : Colors.white,
                    ),
                    label: Text(
                      isFavorite ? 'In List' : 'My List',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
