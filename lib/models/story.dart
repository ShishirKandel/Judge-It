import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for a story in the Judge It app.
/// 
/// Stories are fetched from Firestore and displayed as swipeable cards.
/// Users vote by swiping right (NTA) or left (YTA).
class Story {
  final String id;
  final String title;
  final String body;
  final int yesVotes;
  final int noVotes;
  final String? topComment;  // Top comment from Reddit thread

  Story({
    required this.id,
    required this.title,
    required this.body,
    required this.yesVotes,
    required this.noVotes,
    this.topComment,
  });

  /// Total votes for this story
  int get totalVotes => yesVotes + noVotes;

  /// Percentage of "Not the A**hole" votes (0.0 to 1.0)
  double get ntaPercentage => totalVotes > 0 ? yesVotes / totalVotes : 0.5;

  /// Percentage of "You're the A**hole" votes (0.0 to 1.0)
  double get ytaPercentage => totalVotes > 0 ? noVotes / totalVotes : 0.5;

  /// Whether this story has a top comment
  bool get hasTopComment => topComment != null && topComment!.isNotEmpty;

  /// Create a Story from a Firestore document
  factory Story.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      body: data['body'] ?? '',
      yesVotes: data['yes_votes'] ?? 0,
      noVotes: data['no_votes'] ?? 0,
      topComment: data['top_comment'],
    );
  }

  /// Create a Story from JSON (for local bundled data)
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      body: json['body'] ?? '',
      yesVotes: json['yes_votes'] ?? 0,
      noVotes: json['no_votes'] ?? 0,
      topComment: json['top_comment'],
    );
  }

  /// Convert Story to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'yes_votes': yesVotes,
      'no_votes': noVotes,
      if (topComment != null) 'top_comment': topComment,
    };
  }

  /// Create a copy with updated vote counts
  Story copyWithVote({required bool isYesVote}) {
    return Story(
      id: id,
      title: title,
      body: body,
      yesVotes: isYesVote ? yesVotes + 1 : yesVotes,
      noVotes: isYesVote ? noVotes : noVotes + 1,
      topComment: topComment,
    );
  }
}
