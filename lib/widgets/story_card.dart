import 'package:flutter/material.dart';
import '../models/story.dart';

/// Card widget displaying a story for swiping.
/// 
/// Shows title and body text. Swipe indicators appear during drag.
class StoryCard extends StatelessWidget {
  final Story story;
  final double swipeProgress; // -1.0 to 1.0 (left to right)

  const StoryCard({
    super.key,
    required this.story,
    this.swipeProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1E2E),
            Color(0xFF2D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77), // 0.3 opacity
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withAlpha(77), // 0.3 opacity
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Body text - scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      story.body,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(230), // 0.9 opacity
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Swipe hints at bottom
                _buildSwipeHints(),
              ],
            ),
          ),
          // Swipe direction indicators
          if (swipeProgress != 0) _buildSwipeIndicator(),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (swipeProgress > 0.1) {
      final alpha = (swipeProgress.clamp(0.0, 1.0) * 255).round();
      return Colors.green.withAlpha(alpha);
    } else if (swipeProgress < -0.1) {
      final alpha = ((-swipeProgress).clamp(0.0, 1.0) * 255).round();
      return Colors.red.withAlpha(alpha);
    }
    return Colors.white.withAlpha(26); // 0.1 opacity
  }

  Widget _buildSwipeHints() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left hint
        Row(
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.red.withAlpha(153), // 0.6 opacity
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              'YTA',
              style: TextStyle(
                color: Colors.red.withAlpha(153), // 0.6 opacity
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        // Right hint
        Row(
          children: [
            Text(
              'NTA',
              style: TextStyle(
                color: Colors.green.withAlpha(153), // 0.6 opacity
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.green.withAlpha(153), // 0.6 opacity
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwipeIndicator() {
    final isRight = swipeProgress > 0;
    final alpha = (swipeProgress.abs().clamp(0.0, 1.0) * 255).round();
    
    return Positioned(
      top: 20,
      left: isRight ? null : 20,
      right: isRight ? 20 : null,
      child: Transform.rotate(
        angle: isRight ? 0.2 : -0.2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: (isRight ? Colors.green : Colors.red).withAlpha((alpha * 0.9).round()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withAlpha(128), // 0.5 opacity
              width: 2,
            ),
          ),
          child: Text(
            isRight ? 'NTA' : 'YTA',
            style: TextStyle(
              color: Colors.white.withAlpha(alpha),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
