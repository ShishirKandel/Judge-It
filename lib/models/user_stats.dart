import 'dart:convert';

/// Badge types that can be earned in the app.
enum BadgeType {
  // Beginner badges
  firstJudgment,
  gettingStarted,

  // Volume badges
  fairJudge,
  centurion,
  veteran,

  // Streak badges
  justiceSeeker,
  perfectWeek,
  monthlyMaster,

  // Special badges
  contrarian,
  unanimous,
  balancedJudge,
}

/// Represents a badge that can be earned.
class AppBadge {
  final BadgeType type;
  final String name;
  final String description;
  final String icon;
  final int requirement;

  const AppBadge({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirement,
  });

  static const List<AppBadge> allBadges = [
    // Beginner badges
    AppBadge(
      type: BadgeType.firstJudgment,
      name: 'First Judgment',
      description: 'Complete your first vote',
      icon: '⚖️',
      requirement: 1,
    ),
    AppBadge(
      type: BadgeType.gettingStarted,
      name: 'Getting Started',
      description: 'Complete 10 judgments',
      icon: '🌟',
      requirement: 10,
    ),

    // Volume badges
    AppBadge(
      type: BadgeType.fairJudge,
      name: 'Fair Judge',
      description: '50 total judgments',
      icon: '👨‍⚖️',
      requirement: 50,
    ),
    AppBadge(
      type: BadgeType.centurion,
      name: 'Centurion',
      description: '100 total judgments',
      icon: '🏆',
      requirement: 100,
    ),
    AppBadge(
      type: BadgeType.veteran,
      name: 'Veteran Judge',
      description: '500 total judgments',
      icon: '👑',
      requirement: 500,
    ),

    // Streak badges (consecutive days active)
    AppBadge(
      type: BadgeType.justiceSeeker,
      name: 'Justice Seeker',
      description: '3 day streak',
      icon: '🔥',
      requirement: 3,
    ),
    AppBadge(
      type: BadgeType.perfectWeek,
      name: 'Perfect Week',
      description: '7 day streak',
      icon: '📅',
      requirement: 7,
    ),
    AppBadge(
      type: BadgeType.monthlyMaster,
      name: 'Monthly Master',
      description: '30 day streak',
      icon: '📆',
      requirement: 30,
    ),

    // Special badges
    AppBadge(
      type: BadgeType.contrarian,
      name: 'Contrarian',
      description: 'Disagree with majority 10 times',
      icon: '🎭',
      requirement: 10,
    ),
    AppBadge(
      type: BadgeType.unanimous,
      name: 'Unanimous',
      description: 'Agree with majority 25 times',
      icon: '🤝',
      requirement: 25,
    ),
    AppBadge(
      type: BadgeType.balancedJudge,
      name: 'Balanced Judge',
      description: 'Vote NTA and YTA at least 20 times each',
      icon: '⚖️',
      requirement: 20,
    ),
  ];

  static AppBadge? getBadge(BadgeType type) {
    return allBadges.firstWhere((b) => b.type == type);
  }
}

/// User statistics model for tracking judgment progress.
class UserStats {
  final int totalJudgments;
  final int currentStreak;
  final int bestStreak;
  final int ntaVotes;
  final int ytaVotes;
  final int agreementsWithMajority;
  final int disagreementsWithMajority;
  final Set<BadgeType> earnedBadges;
  final DateTime? lastJudgmentDate;

  const UserStats({
    this.totalJudgments = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.ntaVotes = 0,
    this.ytaVotes = 0,
    this.agreementsWithMajority = 0,
    this.disagreementsWithMajority = 0,
    this.earnedBadges = const {},
    this.lastJudgmentDate,
  });

  /// Accuracy percentage (0.0 to 1.0)
  double get accuracyPercentage {
    final total = agreementsWithMajority + disagreementsWithMajority;
    if (total == 0) return 0.0;
    return agreementsWithMajority / total;
  }

  /// Most common vote tendency
  String get voteTendency {
    if (ntaVotes == 0 && ytaVotes == 0) return 'No votes yet';
    if (ntaVotes > ytaVotes) {
      final ratio = (ntaVotes / (ntaVotes + ytaVotes) * 100).toStringAsFixed(0);
      return 'NTA ($ratio%)';
    } else if (ytaVotes > ntaVotes) {
      final ratio = (ytaVotes / (ntaVotes + ytaVotes) * 100).toStringAsFixed(0);
      return 'YTA ($ratio%)';
    } else {
      return 'Balanced';
    }
  }

  /// Check if a badge should be unlocked based on current stats
  List<BadgeType> checkNewBadges() {
    final newBadges = <BadgeType>[];

    // Beginner badges
    if (!earnedBadges.contains(BadgeType.firstJudgment) && totalJudgments >= 1) {
      newBadges.add(BadgeType.firstJudgment);
    }
    if (!earnedBadges.contains(BadgeType.gettingStarted) && totalJudgments >= 10) {
      newBadges.add(BadgeType.gettingStarted);
    }

    // Volume badges
    if (!earnedBadges.contains(BadgeType.fairJudge) && totalJudgments >= 50) {
      newBadges.add(BadgeType.fairJudge);
    }
    if (!earnedBadges.contains(BadgeType.centurion) && totalJudgments >= 100) {
      newBadges.add(BadgeType.centurion);
    }
    if (!earnedBadges.contains(BadgeType.veteran) && totalJudgments >= 500) {
      newBadges.add(BadgeType.veteran);
    }

    // Streak badges (based on best streak achieved)
    if (!earnedBadges.contains(BadgeType.justiceSeeker) && bestStreak >= 3) {
      newBadges.add(BadgeType.justiceSeeker);
    }
    if (!earnedBadges.contains(BadgeType.perfectWeek) && bestStreak >= 7) {
      newBadges.add(BadgeType.perfectWeek);
    }
    if (!earnedBadges.contains(BadgeType.monthlyMaster) && bestStreak >= 30) {
      newBadges.add(BadgeType.monthlyMaster);
    }

    // Special badges
    if (!earnedBadges.contains(BadgeType.contrarian) && disagreementsWithMajority >= 10) {
      newBadges.add(BadgeType.contrarian);
    }
    if (!earnedBadges.contains(BadgeType.unanimous) && agreementsWithMajority >= 25) {
      newBadges.add(BadgeType.unanimous);
    }
    if (!earnedBadges.contains(BadgeType.balancedJudge) && ntaVotes >= 20 && ytaVotes >= 20) {
      newBadges.add(BadgeType.balancedJudge);
    }

    return newBadges;
  }

  /// Create a copy with updated values after a judgment
  ///
  /// Streak Logic:
  /// - Streak counts consecutive DAYS of activity (not individual judgments)
  /// - First judgment ever = streak starts at 1
  /// - Same day judgment = streak stays the same (already counted today)
  /// - Next day judgment = streak increments by 1
  /// - Gap of 2+ days = streak resets to 1
  ///
  /// Example: Day 1 (judge 5x) -> streak=1, Day 2 (judge 3x) -> streak=2
  UserStats recordJudgment({
    required bool isNta,
    required bool agreedWithMajority,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate streak - tracks consecutive days of activity
    int newStreak = currentStreak;

    if (lastJudgmentDate != null) {
      final lastDate = DateTime(
        lastJudgmentDate!.year,
        lastJudgmentDate!.month,
        lastJudgmentDate!.day,
      );
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 0) {
        // Same day - streak stays the same (we've already counted today)
        // No change to currentStreak
      } else if (daysDiff == 1) {
        // Next consecutive day - increment streak
        newStreak = currentStreak + 1;
      } else {
        // Gap of 2+ days - streak broken, start fresh
        newStreak = 1;
      }
    } else {
      // Very first judgment ever - start streak at 1
      newStreak = 1;
    }

    // Update best streak if current exceeds it
    final newBestStreak = newStreak > bestStreak ? newStreak : bestStreak;

    return UserStats(
      totalJudgments: totalJudgments + 1,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      ntaVotes: isNta ? ntaVotes + 1 : ntaVotes,
      ytaVotes: isNta ? ytaVotes : ytaVotes + 1,
      agreementsWithMajority: agreedWithMajority
          ? agreementsWithMajority + 1
          : agreementsWithMajority,
      disagreementsWithMajority: agreedWithMajority
          ? disagreementsWithMajority
          : disagreementsWithMajority + 1,
      earnedBadges: earnedBadges,
      lastJudgmentDate: now,
    );
  }

  /// Create a copy with new badges added
  UserStats withBadges(Set<BadgeType> badges) {
    return UserStats(
      totalJudgments: totalJudgments,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      ntaVotes: ntaVotes,
      ytaVotes: ytaVotes,
      agreementsWithMajority: agreementsWithMajority,
      disagreementsWithMajority: disagreementsWithMajority,
      earnedBadges: {...earnedBadges, ...badges},
      lastJudgmentDate: lastJudgmentDate,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'totalJudgments': totalJudgments,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'ntaVotes': ntaVotes,
      'ytaVotes': ytaVotes,
      'agreementsWithMajority': agreementsWithMajority,
      'disagreementsWithMajority': disagreementsWithMajority,
      'earnedBadges': earnedBadges.map((b) => b.name).toList(),
      'lastJudgmentDate': lastJudgmentDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory UserStats.fromJson(Map<String, dynamic> json) {
    final badgeNames = (json['earnedBadges'] as List<dynamic>?) ?? [];
    final badges = badgeNames
        .map((name) => BadgeType.values.firstWhere(
              (b) => b.name == name,
              orElse: () => BadgeType.firstJudgment,
            ))
        .toSet();

    return UserStats(
      totalJudgments: json['totalJudgments'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      ntaVotes: json['ntaVotes'] ?? 0,
      ytaVotes: json['ytaVotes'] ?? 0,
      agreementsWithMajority: json['agreementsWithMajority'] ?? 0,
      disagreementsWithMajority: json['disagreementsWithMajority'] ?? 0,
      earnedBadges: badges,
      lastJudgmentDate: json['lastJudgmentDate'] != null
          ? DateTime.parse(json['lastJudgmentDate'])
          : null,
    );
  }

  /// Serialize to string for SharedPreferences
  String serialize() => jsonEncode(toJson());

  /// Deserialize from string
  factory UserStats.deserialize(String data) {
    return UserStats.fromJson(jsonDecode(data));
  }
}
