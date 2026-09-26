import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';
import 'details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHistoryTab(StorageService storage) {
    final history = storage.getWatchHistory();
    if (history.isEmpty) {
      return const Center(
        child: Text('No watch history yet.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = history[idx];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.media.poster,
                width: 44,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceLight, width: 44, height: 60),
              ),
            ),
            title: Text(
              item.media.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: item.progressPercentage,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 4,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(item.progressPercentage * 100).toInt()}% watched',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_fill, color: AppTheme.primary, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailsScreen(media: item.media)),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailsScreen(media: item.media)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab(StorageService storage) {
    final favorites = storage.getFavorites();
    if (favorites.isEmpty) {
      return const Center(
        child: Text('No saved movies in your watchlist.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, idx) => MediaCard(
        media: favorites[idx],
        width: double.infinity,
        height: 160,
      ),
    );
  }

  Widget _buildDownloadsTab(DownloadService downloadService) {
    final tasks = downloadService.tasks;
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No active or completed downloads.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final task = tasks[idx];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(Icons.download_done, color: AppTheme.primary),
            title: Text(
              task.media.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(task.progress * 100).toStringAsFixed(1)}% • ${task.source.quality}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.secondary, size: 20),
              onPressed: () => downloadService.cancelDownload(task.id),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final downloadService = Provider.of<DownloadService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Watchlist'),
            Tab(text: 'Downloads'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(storage),
          _buildFavoritesTab(storage),
          _buildDownloadsTab(downloadService),
        ],
      ),
    );
  }
}
