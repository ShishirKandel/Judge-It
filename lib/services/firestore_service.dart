import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story.dart';

/// Service for interacting with Firestore stories collection.
/// 
/// Handles fetching stories with pagination and updating vote counts.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'stories';

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
    
    await _firestore.collection(_collectionName).doc(storyId).update({
      field: FieldValue.increment(1),
    });
  }
}
