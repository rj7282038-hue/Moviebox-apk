import 'dart:async';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/cinemeta_service.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CinemetaService _cinemetaService = CinemetaService();
  final TextEditingController _textController = TextEditingController();
  Timer? _debounceTimer;

  String _selectedType = 'movie'; // 'movie' or 'series'
  List<MediaItem> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _performSearch(query.trim());
      } else {
        setState(() {
          _results = [];
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final res = await _cinemetaService.search(query, type: _selectedType);
    setState(() {
      _results = res;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies & TV'),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _textController,
              onChanged: _onSearchChanged,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search title, actor, or genre...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _textController.clear();
                          setState(() {
                            _results = [];
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // Type Toggle (Movies vs TV Series)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Movies'),
                  selected: _selectedType == 'movie',
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surfaceLight,
                  labelStyle: TextStyle(
                    color: _selectedType == 'movie' ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedType = 'movie');
                    if (_textController.text.trim().isNotEmpty) {
                      _performSearch(_textController.text.trim());
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('TV Series'),
                  selected: _selectedType == 'series',
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surfaceLight,
                  labelStyle: TextStyle(
                    color: _selectedType == 'series' ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedType = 'series');
                    if (_textController.text.trim().isNotEmpty) {
                      _performSearch(_textController.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.movie_filter, size: 64, color: AppTheme.surfaceLight),
                            SizedBox(height: 12),
                            Text(
                              'Type to find any movie or show across providers',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? const Center(
                            child: Text(
                              'No titles matched your search.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.62,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _results.length,
                            itemBuilder: (context, idx) {
                              return MediaCard(
                                media: _results[idx],
                                width: double.infinity,
                                height: 160,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
