import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'livetv_screen.dart';
import 'addons_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LiveTvScreen(),
    AddonsScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppTheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF00838F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.movie_filter_rounded, size: 48, color: Colors.black),
                  SizedBox(height: 10),
                  Text(
                    'MovieBox Mobile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'TUI Engine • Mobile Edition',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppTheme.primary),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: AppTheme.primary),
              title: const Text('Search', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.live_tv, color: AppTheme.primary),
              title: const Text('Live TV & IPTV', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.extension, color: AppTheme.primary),
              title: const Text('Stremio Addons', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: AppTheme.primary),
              title: const Text('My Library', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            const Divider(color: AppTheme.surfaceLight),
            ListTile(
              leading: const Icon(Icons.settings, color: AppTheme.textSecondary),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv_outlined),
            activeIcon: Icon(Icons.live_tv),
            label: 'Live TV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension_outlined),
            activeIcon: Icon(Icons.extension),
            label: 'Addons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
