import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../services/firestore_service.dart';
import '../services/local_data_service.dart';

/// Data source type for tracking where stories come from.
enum DataSource { firebase, local }

/// Repository that provides seamless switching between Firebase and local data.
/// 
/// Tries Firebase first with timeout, falls back to local data on failure.
class StoryRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final LocalDataService _localDataService = LocalDataService();
  
  /// Current data source being used
  DataSource _currentSource = DataSource.firebase;
  
  /// Timeout for Firebase requests
  static const Duration _firebaseTimeout = Duration(seconds: 5);
  
  /// Last Firestore document for pagination
  DocumentSnapshot? _lastDocument;
  
  /// Whether we've exhausted Firebase stories
  bool _firebaseHasMore = true;
  
  // Getters
  DataSource get currentSource => _currentSource;
  bool get isUsingLocalData => _currentSource == DataSource.local;

  /// Fetches stories with automatic fallback.
  /// 
  /// Tries Firebase first, falls back to local if:
  /// - Request times out
  /// - Network error occurs
  /// - Firebase quota exceeded
  Future<List<Story>> fetchStories({int limit = 5}) async {
    // If already using local data, continue with local
    if (_currentSource == DataSource.local) {
      return _fetchFromLocal(limit);
    }
    
    // Try Firebase with timeout
    try {
      final stories = await _fetchFromFirebase(limit)
          .timeout(_firebaseTimeout);
      
      if (stories.isNotEmpty) {
        return stories;
      }
      
      // Firebase returned empty - either no more or issue
      if (!_firebaseHasMore) {
        // Truly exhausted Firebase, switch to local
        debugPrint('📱 Firebase exhausted, switching to local data');
        _currentSource = DataSource.local;
        return _fetchFromLocal(limit);
      }
      
      return stories;
    } on TimeoutException {
      debugPrint('⏱️ Firebase timeout, switching to local data');
      _currentSource = DataSource.local;
      return _fetchFromLocal(limit);
    } catch (e) {
      debugPrint('❌ Firebase error: $e, switching to local data');
      _currentSource = DataSource.local;
      return _fetchFromLocal(limit);
    }
  }

  Future<List<Story>> _fetchFromFirebase(int limit) async {
    final result = await _firestoreService.fetchStories(
      limit: limit,
      lastDocument: _lastDocument,
    );
    
    if (result.stories.isEmpty) {
      _firebaseHasMore = false;
    } else {
      _lastDocument = result.lastDoc;
    }
    
    return result.stories;
  }

  Future<List<Story>> _fetchFromLocal(int limit) async {
    return _localDataService.fetchStories(limit: limit);
  }

  /// Increments vote count.
  /// 
  /// If using Firebase, updates Firestore.
  /// Votes are tracked locally regardless.
  Future<void> incrementVote(String storyId, bool isYesVote) async {
    if (_currentSource == DataSource.firebase) {
      try {
        await _firestoreService.incrementVote(storyId, isYesVote)
            .timeout(_firebaseTimeout);
      } catch (e) {
        // Vote failed to record, but don't fail silently
        debugPrint('Failed to record vote to Firebase: $e');
      }
    }
    // For local data, votes are only tracked in memory (this session)
  }

  /// Checks if more stories are available.
  Future<bool> get hasMore async {
    if (_currentSource == DataSource.firebase) {
      return _firebaseHasMore;
    }
    return _localDataService.hasMore;
  }

  /// Resets repository state.
  void reset() {
    _currentSource = DataSource.firebase;
    _lastDocument = null;
    _firebaseHasMore = true;
    _localDataService.reset();
  }

  /// Force switch to local data (for testing or user preference).
  void useLocalData() {
    _currentSource = DataSource.local;
    debugPrint('📱 Forced switch to local data');
  }

  /// Force retry Firebase (after being in local mode).
  void retryFirebase() {
    _currentSource = DataSource.firebase;
    _firebaseHasMore = true;
    debugPrint('☁️ Retrying Firebase');
  }
}
