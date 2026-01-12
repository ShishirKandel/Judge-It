import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../services/firestore_service.dart';
import '../services/ad_service.dart';

/// Vote type enum for clarity
enum VoteType { nta, yta }

/// State provider for the swipe screen.
/// 
/// Manages story fetching, pagination, voting, swipe counting, and ad logic.
class SwipeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AdService _adService = AdService();

  // Story management
  final List<Story> _stories = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  // Swipe and ad logic
  int _swipeCount = 0;
  static const int _adInterval = 7;

  // Current result to show after swipe
  Story? _lastVotedStory;
  VoteType? _lastVoteType;
  bool _showingResult = false;

  // Getters
  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get swipeCount => _swipeCount;
  Story? get lastVotedStory => _lastVotedStory;
  VoteType? get lastVoteType => _lastVoteType;
  bool get showingResult => _showingResult;

  /// Number of stories per fetch batch
  static const int _batchSize = 5;

  /// Threshold to trigger pre-fetch (when this many cards remain)
  static const int _prefetchThreshold = 2;

  /// Initialize and fetch first batch of stories
  Future<void> initialize() async {
    await fetchMoreStories();
  }

  /// Fetch more stories from Firestore
  Future<void> fetchMoreStories() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _firestoreService.fetchStories(
        limit: _batchSize,
        lastDocument: _lastDocument,
      );

      if (result.stories.isEmpty) {
        _hasMore = false;
      } else {
        _stories.addAll(result.stories);
        _lastDocument = result.lastDoc;
      }
    } catch (e) {
      _error = 'Failed to load stories: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle a swipe action
  /// 
  /// [storyIndex] - Index of the swiped story in the current list
  /// [isRightSwipe] - True for NTA (right), false for YTA (left)
  Future<void> onSwipe(int storyIndex, bool isRightSwipe) async {
    if (storyIndex >= _stories.length) return;

    final story = _stories[storyIndex];
    final voteType = isRightSwipe ? VoteType.nta : VoteType.yta;

    // Calculate result with user's vote included
    _lastVotedStory = story.copyWithVote(isYesVote: isRightSwipe);
    _lastVoteType = voteType;
    _showingResult = true;
    notifyListeners();

    // Increment swipe counter and check for ad
    _swipeCount++;
    if (_swipeCount % _adInterval == 0) {
      _adService.showInterstitialAd();
    }

    // Update Firestore in background (fire and forget)
    _firestoreService.incrementVote(story.id, isRightSwipe).catchError((e) {
      debugPrint('Failed to record vote: $e');
    });

    // Pre-fetch more stories if running low
    final remainingCards = _stories.length - storyIndex - 1;
    if (remainingCards <= _prefetchThreshold && _hasMore) {
      fetchMoreStories();
    }
  }

  /// Dismiss the result overlay
  void dismissResult() {
    _showingResult = false;
    _lastVotedStory = null;
    _lastVoteType = null;
    notifyListeners();
  }

  /// Get agreement percentage for the last vote
  double get agreementPercentage {
    if (_lastVotedStory == null || _lastVoteType == null) return 0.0;
    
    return _lastVoteType == VoteType.nta 
        ? _lastVotedStory!.ntaPercentage 
        : _lastVotedStory!.ytaPercentage;
  }

  /// Reset state (for pull-to-refresh or retry)
  Future<void> reset() async {
    _stories.clear();
    _lastDocument = null;
    _hasMore = true;
    _error = null;
    _swipeCount = 0;
    _showingResult = false;
    notifyListeners();
    await fetchMoreStories();
  }
}
