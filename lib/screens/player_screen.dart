import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/media_item.dart';
import '../models/stream_source.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem media;
  final StreamSource streamSource;
  final int? season;
  final int? episode;
  final StorageService storageService;

  const PlayerScreen({
    Key? key,
    required this.media,
    required this.streamSource,
    this.season,
    this.episode,
    required this.storageService,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  Timer? _progressSaveTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Set fullscreen landscape for immersive movie watching
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final uri = Uri.parse(widget.streamSource.url);
      _controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: widget.streamSource.headers ?? {},
      );

      await _controller.initialize();

      // Check if we have saved progress to resume (MovieBox-TUI feature!)
      final history = widget.storageService.getWatchHistory();
      final existing = history.where((h) => h.media.id == widget.media.id).toList();
      if (existing.isNotEmpty && existing.first.positionSeconds > 10) {
        final pos = Duration(seconds: existing.first.positionSeconds);
        if (pos < _controller.value.duration) {
          await _controller.seekTo(pos);
        }
      }

      _controller.play();

      setState(() {
        _isInitialized = true;
      });

      _startHideControlsTimer();
      _startProgressSaveTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load stream. Try another stream link or external player.';
      });
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _startProgressSaveTimer() {
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isInitialized && _controller.value.isPlaying) {
        widget.storageService.saveWatchProgress(
          media: widget.media,
          positionSeconds: _controller.value.position.inSeconds,
          durationSeconds: _controller.value.duration.inSeconds,
          season: widget.season,
          episode: widget.episode,
        );
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _progressSaveTimer?.cancel();

    if (_isInitialized) {
      widget.storageService.saveWatchProgress(
        media: widget.media,
        positionSeconds: _controller.value.position.inSeconds,
        durationSeconds: _controller.value.duration.inSeconds,
        season: widget.season,
        episode: widget.episode,
      );
      _controller.dispose();
    }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.episode != null
        ? '${widget.media.name} (S${widget.season} E${widget.episode})'
        : widget.media.name;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
          if (_showControls) _startHideControlsTimer();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Output
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio > 0
                      ? _controller.value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(_controller),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.secondary, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),

            // Controls Overlay
            if (_isInitialized && _showControls)
              Container(
                color: Colors.black45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.primary),
                              ),
                              child: Text(
                                widget.streamSource.quality,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Middle Play/Rewind/Forward Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 42,
                          icon: const Icon(Icons.replay_10, color: Colors.white),
                          onPressed: () {
                            final pos = _controller.value.position - const Duration(seconds: 10);
                            _controller.seekTo(pos > Duration.zero ? pos : Duration.zero);
                            _startHideControlsTimer();
                          },
                        ),
                        const SizedBox(width: 32),
                        IconButton(
                          iconSize: 64,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: AppTheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                            _startHideControlsTimer();
                          },
                        ),
                        const SizedBox(width: 32),
                        IconButton(
                          iconSize: 42,
                          icon: const Icon(Icons.forward_10, color: Colors.white),
                          onPressed: () {
                            final pos = _controller.value.position + const Duration(seconds: 10);
                            _controller.seekTo(pos);
                            _startHideControlsTimer();
                          },
                        ),
                      ],
                    ),

                    // Bottom Bar with Progress Slider
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: AppTheme.primary,
                                bufferedColor: Colors.white24,
                                backgroundColor: Colors.white10,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: _controller,
                                  builder: (context, VideoPlayerValue value, _) {
                                    return Text(
                                      '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    );
                                  },
                                ),
                                Text(
                                  widget.streamSource.providerName,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
