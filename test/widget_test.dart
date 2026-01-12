// Basic Flutter widget test for Judge It app.

import 'package:flutter_test/flutter_test.dart';
import 'package:judge_it/models/story.dart';

void main() {
  group('Story Model Tests', () {
    test('Story calculates NTA percentage correctly', () {
      final story = Story(
        id: 'test-1',
        title: 'Test Story',
        body: 'Test body content',
        yesVotes: 80,
        noVotes: 20,
      );

      expect(story.totalVotes, 100);
      expect(story.ntaPercentage, 0.8);
      expect(story.ytaPercentage, 0.2);
    });

    test('Story copyWithVote increments correctly', () {
      final story = Story(
        id: 'test-2',
        title: 'Test Story',
        body: 'Test body content',
        yesVotes: 50,
        noVotes: 50,
      );

      final afterYesVote = story.copyWithVote(isYesVote: true);
      expect(afterYesVote.yesVotes, 51);
      expect(afterYesVote.noVotes, 50);

      final afterNoVote = story.copyWithVote(isYesVote: false);
      expect(afterNoVote.yesVotes, 50);
      expect(afterNoVote.noVotes, 51);
    });

    test('Story handles zero votes gracefully', () {
      final story = Story(
        id: 'test-3',
        title: 'New Story',
        body: 'No votes yet',
        yesVotes: 0,
        noVotes: 0,
      );

      expect(story.totalVotes, 0);
      expect(story.ntaPercentage, 0.5); // Default to 50%
      expect(story.ytaPercentage, 0.5);
    });
  });
}
