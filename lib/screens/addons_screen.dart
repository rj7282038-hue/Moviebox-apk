import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stremio_addon.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AddonsScreen extends StatefulWidget {
  const AddonsScreen({Key? key}) : super(key: key);

  @override
  State<AddonsScreen> createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  void _showAddAddonDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Add Stremio Addon', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the manifest URL for any community Stremio addon (e.g. https://torrentio.strem.fun/manifest.json).',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Addon Name',
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'Manifest URL',
                hintText: 'https://.../manifest.json',
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
                hintStyle: const TextStyle(color: Colors.white24),
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
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                final storage = Provider.of<StorageService>(context, listen: false);
                await storage.addCustomAddon(
                  StremioAddon(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    name: name.isNotEmpty ? name : 'Custom Addon',
                    description: 'Custom community stream provider',
                    manifestUrl: url,
                  ),
                );
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Install', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final addons = storage.getAddons();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Addon Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primary),
            tooltip: 'Install Custom Addon',
            onPressed: _showAddAddonDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primary, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'MovieBox-TUI Addon Protocol: Streams are concurrently scraped across all active addons simultaneously.',
                    style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Installed Providers & Addons',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          ...addons.map((addon) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                title: Row(
                  children: [
                    Text(
                      addon.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    if (addon.isProtected) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'CORE',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  addon.description,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
                activeColor: AppTheme.primary,
                value: addon.isEnabled,
                onChanged: addon.isProtected
                    ? null
                    : (val) {
                        storage.toggleAddon(addon.id, val);
                        setState(() {});
                      },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
