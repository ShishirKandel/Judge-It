import 'package:flutter/foundation.dart';
import '../models/user_stats.dart';
import '../services/stats_service.dart';

/// Provider for managing user statistics state.
///
/// Handles loading, updating, and persisting user stats including
/// judgments, streaks, accuracy, and badges.
class StatsProvider extends ChangeNotifier {
  final StatsService _service = StatsService();

  UserStats _stats = const UserStats();
  bool _isInitialized = false;
  List<BadgeType> _recentlyUnlockedBadges = [];

  // Getters
  UserStats get stats => _stats;
  bool get isInitialized => _isInitialized;
  List<BadgeType> get recentlyUnlockedBadges => _recentlyUnlockedBadges;

  // Convenience getters for UI
  int get totalJudgments => _stats.totalJudgments;
  int get currentStreak => _stats.currentStreak;
  int get bestStreak => _stats.bestStreak;
  double get accuracyPercentage => _stats.accuracyPercentage;
  String get voteTendency => _stats.voteTendency;
  Set<BadgeType> get earnedBadges => _stats.earnedBadges;
  int get ntaVotes => _stats.ntaVotes;
  int get ytaVotes => _stats.ytaVotes;

  /// Initialize the provider by loading saved stats
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _service.initialize();
    _stats = await _service.loadStats();
    _isInitialized = true;
    notifyListeners();
  }

  /// Record a new judgment and check for new badges
  ///
  /// Returns list of newly unlocked badges (if any)
  Future<List<BadgeType>> recordJudgment({
    required bool isNta,
    required bool agreedWithMajority,
  }) async {
    // Update stats
    _stats = _stats.recordJudgment(
      isNta: isNta,
      agreedWithMajority: agreedWithMajority,
    );

    // Check for new badges
    final newBadges = _stats.checkNewBadges();
    if (newBadges.isNotEmpty) {
      _stats = _stats.withBadges(newBadges.toSet());
      _recentlyUnlockedBadges = newBadges;
    } else {
      _recentlyUnlockedBadges = [];
    }

    // Persist changes
    await _service.saveStats(_stats);
    notifyListeners();

    return newBadges;
  }

  /// Clear the recently unlocked badges list
  void clearRecentBadges() {
    _recentlyUnlockedBadges = [];
    notifyListeners();
  }

  /// Reset all stats (for testing)
  Future<void> resetStats() async {
    _stats = const UserStats();
    _recentlyUnlockedBadges = [];
    await _service.clearStats();
    notifyListeners();
  }

  /// Get badge info for display
  List<AppBadge> get allBadges => AppBadge.allBadges;

  /// Check if a specific badge is earned
  bool hasBadge(BadgeType type) => _stats.earnedBadges.contains(type);

  /// Get progress towards a badge (0.0 to 1.0)
  double getBadgeProgress(BadgeType type) {
    final badge = AppBadge.getBadge(type);
    if (badge == null) return 0.0;
    if (hasBadge(type)) return 1.0;

    switch (type) {
      // Beginner badges
      case BadgeType.firstJudgment:
        return _stats.totalJudgments > 0 ? 1.0 : 0.0;
      case BadgeType.gettingStarted:
        return (_stats.totalJudgments / badge.requirement).clamp(0.0, 1.0);

      // Volume badges
      case BadgeType.fairJudge:
      case BadgeType.centurion:
      case BadgeType.veteran:
        return (_stats.totalJudgments / badge.requirement).clamp(0.0, 1.0);

      // Streak badges (use bestStreak for progress)
      case BadgeType.justiceSeeker:
      case BadgeType.perfectWeek:
      case BadgeType.monthlyMaster:
        return (_stats.bestStreak / badge.requirement).clamp(0.0, 1.0);

      // Special badges
      case BadgeType.contrarian:
        return (_stats.disagreementsWithMajority / badge.requirement).clamp(0.0, 1.0);
      case BadgeType.unanimous:
        return (_stats.agreementsWithMajority / badge.requirement).clamp(0.0, 1.0);
      case BadgeType.balancedJudge:
        // Progress is minimum of both vote types
        final minVotes = _stats.ntaVotes < _stats.ytaVotes
            ? _stats.ntaVotes
            : _stats.ytaVotes;
        return (minVotes / badge.requirement).clamp(0.0, 1.0);
    }
  }
}
