import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../repositories/story_repository.dart';
import '../services/ad_service.dart';

/// Vote type enum for clarity
enum VoteType { nta, yta }

/// State provider for the swipe screen.
/// 
/// Manages story fetching, pagination, voting, swipe counting, and ad logic.
/// Uses StoryRepository for seamless Firebase/offline switching.
class SwipeProvider extends ChangeNotifier {
  final StoryRepository _repository = StoryRepository();
  final AdService _adService = AdService();

  // Story management
  final List<Story> _stories = [];
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
  
  /// Whether using local data (for UI indicator)
  bool get isOfflineMode => _repository.isUsingLocalData;
  DataSource get dataSource => _repository.currentSource;

  /// Number of stories per fetch batch
  static const int _batchSize = 5;

  /// Threshold to trigger pre-fetch (when this many cards remain)
  static const int _prefetchThreshold = 2;

  /// Initialize and fetch first batch of stories
  Future<void> initialize() async {
    await fetchMoreStories();
  }

  /// Fetch more stories (automatically handles Firebase/offline switching)
  Future<void> fetchMoreStories() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newStories = await _repository.fetchStories(limit: _batchSize);

      if (newStories.isEmpty) {
        _hasMore = await _repository.hasMore;
      } else {
        _stories.addAll(newStories);
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

    // Update vote in repository (handles Firebase/offline automatically)
    _repository.incrementVote(story.id, isRightSwipe).catchError((e) {
      debugPrint('Failed to record vote: $e');
    });

    // Pre-fetch more stories if running low
    final remainingCards = _stories.length - storyIndex - 1;
    if (remainingCards <= _prefetchThreshold && _hasMore) {
      fetchMoreStories();
    }
  }

  /// Handle skip action (swipe up)
  /// 
  /// [storyIndex] - Index of the skipped story
  void onSkip(int storyIndex) {
    if (storyIndex >= _stories.length) return;

    // Don't show result, just move to next card
    _swipeCount++;  // Still counts towards ad interval
    
    // Check for ad on skip too
    if (_swipeCount % _adInterval == 0) {
      _adService.showInterstitialAd();
    }

    // Pre-fetch more stories if running low
    final remainingCards = _stories.length - storyIndex - 1;
    if (remainingCards <= _prefetchThreshold && _hasMore) {
      fetchMoreStories();
    }
    
    notifyListeners();
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
    _hasMore = true;
    _error = null;
    _swipeCount = 0;
    _showingResult = false;
    _repository.reset();
    notifyListeners();
    await fetchMoreStories();
  }

  /// Force retry Firebase connection
  Future<void> retryOnline() async {
    _repository.retryFirebase();
    await reset();
  }
}
