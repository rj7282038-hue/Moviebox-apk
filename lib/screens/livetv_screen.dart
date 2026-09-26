import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/iptv_channel.dart';
import '../services/iptv_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({Key? key}) : super(key: key);

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  final IptvService _iptvService = IptvService();
  List<IptvChannel> _allChannels = [];
  List<IptvChannel> _filteredChannels = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Mini live player state
  IptvChannel? _activeChannel;
  VideoPlayerController? _liveController;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() => _isLoading = true);
    final storage = Provider.of<StorageService>(context, listen: false);
    final customUrl = storage.getCustomM3uUrl();

    final channels = await _iptvService.loadPlaylist(customUrl);
    setState(() {
      _allChannels = channels;
      _applyFilter();
      _isLoading = false;
      if (_allChannels.isNotEmpty) {
        _playChannel(_allChannels.first);
      }
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredChannels = _allChannels.where((c) {
        final matchesCat = _selectedCategory == 'All' ||
            c.group.toLowerCase().contains(_selectedCategory.toLowerCase());
        final matchesSearch = _searchQuery.isEmpty ||
            c.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCat && matchesSearch;
      }).toList();
    });
  }

  Future<void> _playChannel(IptvChannel channel) async {
    _liveController?.dispose();
    setState(() {
      _activeChannel = channel;
      _isPlayerInitialized = false;
    });

    try {
      _liveController = VideoPlayerController.networkUrl(Uri.parse(channel.url));
      await _liveController!.initialize();
      _liveController!.play();
      setState(() {
        _isPlayerInitialized = true;
      });
    } catch (_) {
      // Stream error
    }
  }

  void _showAddM3uDialog() {
    final textController = TextEditingController();
    final storage = Provider.of<StorageService>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Add M3U Playlist', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste any M3U or M3U8 playlist URL to import live channels (like MovieBox-TUI).',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'https://example.com/playlist.m3u',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              final url = textController.text.trim();
              if (url.isNotEmpty) {
                await storage.setCustomM3uUrl(url);
                Navigator.pop(ctx);
                _loadChannels();
              }
            },
            child: const Text('Load', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _liveController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Sports', 'News', 'Movies', 'Science', 'Entertainment'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live TV & IPTV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add, color: AppTheme.primary),
            tooltip: 'Add Custom M3U Playlist',
            onPressed: _showAddM3uDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChannels,
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Video Screen Area
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.black,
            child: _activeChannel != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isPlayerInitialized && _liveController != null)
                        AspectRatio(
                          aspectRatio: _liveController!.value.aspectRatio > 0
                              ? _liveController!.value.aspectRatio
                              : 16 / 9,
                          child: VideoPlayer(_liveController!),
                        )
                      else
                        const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                      // Live badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(radius: 4, backgroundColor: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Channel Name banner
                      Positioned(
                        bottom: 8,
                        left: 12,
                        right: 12,
                        child: Text(
                          _activeChannel!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text('Select a channel to start streaming', style: TextStyle(color: Colors.white54)),
                  ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) {
                _searchQuery = val;
                _applyFilter();
              },
              decoration: InputDecoration(
                hintText: 'Search channel name...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                        _applyFilter();
                      });
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surfaceLight,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Channel List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _filteredChannels.isEmpty
                    ? const Center(
                        child: Text(
                          'No channels found in this category.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredChannels.length,
                        itemBuilder: (context, idx) {
                          final channel = _filteredChannels[idx];
                          final isPlaying = _activeChannel?.url == channel.url;
                          return ListTile(
                            tileColor: isPlaying ? AppTheme.surfaceLight : Colors.transparent,
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: channel.logo.isNotEmpty
                                  ? Image.network(
                                      channel.logo,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.tv,
                                        color: AppTheme.primary,
                                      ),
                                    )
                                  : const Icon(Icons.tv, color: AppTheme.primary),
                            ),
                            title: Text(
                              channel.name,
                              style: TextStyle(
                                color: isPlaying ? AppTheme.primary : AppTheme.textPrimary,
                                fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              channel.group,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            trailing: isPlaying
                                ? const Icon(Icons.graphic_eq, color: AppTheme.primary)
                                : const Icon(Icons.play_arrow, color: AppTheme.textSecondary),
                            onTap: () => _playChannel(channel),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
