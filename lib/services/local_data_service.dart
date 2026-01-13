import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/story.dart';

/// Service for loading stories from bundled local JSON data.
/// 
/// Used as fallback when Firebase is unavailable or for offline mode.
class LocalDataService {
  static const String _assetPath = 'assets/data/stories.json';
  
  List<Story>? _cachedStories;
  int _currentIndex = 0;

  /// Loads all stories from the bundled JSON asset.
  /// Results are cached for subsequent calls.
  Future<List<Story>> _loadAllStories() async {
    if (_cachedStories != null) {
      return _cachedStories!;
    }

    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> storiesJson = data['stories'] ?? [];
      
      _cachedStories = storiesJson.map((json) => Story.fromJson(json)).toList();
      
      // Shuffle for variety each session
      _cachedStories!.shuffle();
      
      return _cachedStories!;
    } catch (e) {
      throw Exception('Failed to load local stories: $e');
    }
  }

  /// Fetches a batch of stories (mimics pagination).
  /// 
  /// [limit] - Number of stories to fetch
  /// 
  /// Returns a list of Story objects.
  Future<List<Story>> fetchStories({int limit = 5}) async {
    final allStories = await _loadAllStories();
    
    if (_currentIndex >= allStories.length) {
      return []; // No more stories
    }
    
    final endIndex = (_currentIndex + limit).clamp(0, allStories.length);
    final batch = allStories.sublist(_currentIndex, endIndex);
    _currentIndex = endIndex;
    
    return batch;
  }

  /// Resets pagination to start from the beginning.
  void reset() {
    _currentIndex = 0;
    // Re-shuffle for variety
    _cachedStories?.shuffle();
  }

  /// Gets total number of available stories.
  Future<int> get totalStories async {
    final stories = await _loadAllStories();
    return stories.length;
  }

  /// Checks if more stories are available.
  Future<bool> get hasMore async {
    final stories = await _loadAllStories();
    return _currentIndex < stories.length;
  }
}
