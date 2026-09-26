import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/media_item.dart';
import '../models/stream_source.dart';
import '../services/stremio_service.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';
import '../theme/app_theme.dart';
import '../screens/player_screen.dart';

class StreamSelectorModal extends StatefulWidget {
  final MediaItem media;
  final int? season;
  final int? episode;
  final StorageService storageService;
  final DownloadService downloadService;

  const StreamSelectorModal({
    Key? key,
    required this.media,
    this.season,
    this.episode,
    required this.storageService,
    required this.downloadService,
  }) : super(key: key);

  @override
  State<StreamSelectorModal> createState() => _StreamSelectorModalState();
}

class _StreamSelectorModalState extends State<StreamSelectorModal> {
  final StremioService _stremioService = StremioService();
  bool _isLoading = true;
  List<StreamSource> _streams = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveStreams();
  }

  Future<void> _resolveStreams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final addons = widget.storageService.getAddons();
      final results = await _stremioService.resolveStreams(
        imdbId: widget.media.id,
        type: widget.media.type,
        season: widget.season,
        episode: widget.episode,
        addons: addons,
      );

      setState(() {
        _streams = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load streams. Please check addons.';
        _isLoading = false;
      });
    }
  }

  void _playStream(StreamSource stream) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          media: widget.media,
          streamSource: stream,
          season: widget.season,
          episode: widget.episode,
          storageService: widget.storageService,
        ),
      ),
    );
  }

  Future<void> _playInExternalPlayer(StreamSource stream) async {
    final uri = Uri.parse(stream.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch external player')),
        );
      }
    }
  }

  Color _getQualityColor(String q) {
    switch (q.toUpperCase()) {
      case '4K':
        return Colors.purpleAccent;
      case '1080P':
        return AppTheme.primary;
      case '720P':
        return Colors.amber;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Streams',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.episode != null
                        ? 'Season ${widget.season} • Episode ${widget.episode}'
                        : widget.media.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primary),
                onPressed: _resolveStreams,
              ),
            ],
          ),
          const Divider(color: AppTheme.surfaceLight, height: 24),

          // Content
          if (_isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 14),
                    Text(
                      'Resolving streams across addons...',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_error != null) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(_error!, style: const TextStyle(color: AppTheme.secondary)),
              ),
            ),
          ] else if (_streams.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  'No stream links found. Try enabling more addons.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ] else ...[
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _streams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final stream = _streams[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getQualityColor(stream.quality).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getQualityColor(stream.quality).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          stream.quality,
                          style: TextStyle(
                            color: _getQualityColor(stream.quality),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        stream.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            stream.providerName,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          ),
                          if (stream.size != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${stream.size}',
                              style: const TextStyle(color: AppTheme.primary, fontSize: 11),
                            ),
                          ],
                          if (stream.seeds != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• 👤 ${stream.seeds}',
                              style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, size: 20, color: AppTheme.primary),
                            onPressed: () {
                              widget.downloadService.startDownload(widget.media, stream);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Download started in background')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 20, color: AppTheme.textSecondary),
                            onPressed: () => _playInExternalPlayer(stream),
                            tooltip: 'External Player (VLC)',
                          ),
                        ],
                      ),
                      onTap: () => _playStream(stream),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
