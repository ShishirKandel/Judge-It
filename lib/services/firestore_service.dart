import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story.dart';

/// Global app stats from Firestore.
class GlobalAppStats {
  final int totalJudgments;
  final int activeUsersToday;
  final int storiesJudgedToday;

  const GlobalAppStats({
    this.totalJudgments = 0,
    this.activeUsersToday = 0,
    this.storiesJudgedToday = 0,
  });

  factory GlobalAppStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return const GlobalAppStats();
    return GlobalAppStats(
      totalJudgments: data['total_judgments'] ?? 0,
      activeUsersToday: data['active_users_today'] ?? 0,
      storiesJudgedToday: data['stories_judged_today'] ?? 0,
    );
  }
}

/// Service for interacting with Firestore stories collection.
///
/// Handles fetching stories with pagination, updating vote counts,
/// and realtime listeners for live data.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'stories';
  static const String _appStatsCollection = 'app_stats';
  static const String _globalStatsDoc = 'global';

  /// Fetches a batch of stories for infinite scrolling.
  /// 
  /// [limit] - Number of stories to fetch (default: 5)
  /// [lastDocument] - Last document from previous fetch for pagination
  /// 
  /// Returns a list of Story objects and the last DocumentSnapshot for pagination.
  Future<({List<Story> stories, DocumentSnapshot? lastDoc})> fetchStories({
    int limit = 5,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection(_collectionName)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      return (stories: <Story>[], lastDoc: null);
    }

    final stories = snapshot.docs.map((doc) => Story.fromFirestore(doc)).toList();
    final lastDoc = snapshot.docs.last;

    return (stories: stories, lastDoc: lastDoc);
  }

  /// Increments the vote count for a story.
  ///
  /// [storyId] - The ID of the story to update
  /// [isYesVote] - True for NTA vote (yes), false for YTA vote (no)
  Future<void> incrementVote(String storyId, bool isYesVote) async {
    final field = isYesVote ? 'yes_votes' : 'no_votes';

    // Update story votes
    await _firestore.collection(_collectionName).doc(storyId).update({
      field: FieldValue.increment(1),
      'last_voted_at': FieldValue.serverTimestamp(),
      'votes_today': FieldValue.increment(1),
    });

    // Also update global app stats
    await _incrementGlobalStats();
  }

  /// Increment global app stats when a vote is cast.
  Future<void> _incrementGlobalStats() async {
    try {
      await _firestore
          .collection(_appStatsCollection)
          .doc(_globalStatsDoc)
          .update({
        'total_judgments': FieldValue.increment(1),
        'stories_judged_today': FieldValue.increment(1),
      });
    } catch (e) {
      // If document doesn't exist, create it
      await _firestore
          .collection(_appStatsCollection)
          .doc(_globalStatsDoc)
          .set({
        'total_judgments': 1,
        'active_users_today': 1,
        'stories_judged_today': 1,
        'last_reset': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get a realtime stream of a specific story's data.
  ///
  /// Useful for showing live vote count updates on result overlay.
  Stream<Story?> watchStory(String storyId) {
    return _firestore
        .collection(_collectionName)
        .doc(storyId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Story.fromFirestore(doc);
    });
  }

  /// Get a realtime stream of global app stats.
  ///
  /// Uses Firestore's built-in real-time listeners (internally uses WebSocket-like
  /// long-polling connections). When any client updates the app_stats/global document,
  /// all listening clients receive the update automatically.
  ///
  /// This is NOT a raw WebSocket - Firestore handles the connection management,
  /// reconnection, and offline persistence automatically.
  Stream<GlobalAppStats> watchGlobalStats() {
    return _firestore
        .collection(_appStatsCollection)
        .doc(_globalStatsDoc)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return const GlobalAppStats();
      return GlobalAppStats.fromFirestore(doc);
    });
  }

  /// Fetch global stats once (non-realtime).
  Future<GlobalAppStats> fetchGlobalStats() async {
    try {
      final doc = await _firestore
          .collection(_appStatsCollection)
          .doc(_globalStatsDoc)
          .get();
      if (!doc.exists) return const GlobalAppStats();
      return GlobalAppStats.fromFirestore(doc);
    } catch (e) {
      return const GlobalAppStats();
    }
  }
}
