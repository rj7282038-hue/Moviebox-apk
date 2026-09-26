import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final currentQuality = storage.getPreferredQuality();
    final useExternal = storage.getUseExternalPlayer();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Config'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Playback & Stream Quality',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Default Stream Quality', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Preferred resolution when auto-resolving streams ($currentQuality)',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  trailing: DropdownButton<String>(
                    value: currentQuality,
                    dropdownColor: AppTheme.surfaceLight,
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: '4K', child: Text('4K UHD')),
                      DropdownMenuItem(value: '1080p', child: Text('1080p FHD')),
                      DropdownMenuItem(value: '720p', child: Text('720p HD')),
                      DropdownMenuItem(value: '480p', child: Text('480p SD')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        storage.setPreferredQuality(val);
                        setState(() {});
                      }
                    },
                  ),
                ),
                const Divider(color: AppTheme.surfaceLight, height: 1),
                SwitchListTile(
                  title: const Text('Use External Video Player', style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    'Launch streams directly in VLC, MX Player, or Just Player',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  activeColor: AppTheme.primary,
                  value: useExternal,
                  onChanged: (val) {
                    storage.setUseExternalPlayer(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Data & Storage',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.secondary),
              title: const Text('Clear Watch History', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Reset all saved playback progress and resume checkpoints',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              onTap: () async {
                await storage.clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Watch history cleared')),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'About MovieBox Mobile',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'MovieBox Mobile v1.0.0',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Inspired by MovieBox-TUI by mesamirh.\nProvides cross-provider streaming, Cinemeta metadata, Stremio addon protocol, and M3U Live TV.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
