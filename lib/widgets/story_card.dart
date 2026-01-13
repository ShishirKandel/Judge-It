import 'package:flutter/material.dart';
import '../models/story.dart';
import '../theme/app_colors.dart';

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
          colors: [AppColors.surface, AppColors.surfaceLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black30,
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.white30,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      story.body,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white90,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwipeHints(),
              ],
            ),
          ),
          if (swipeProgress != 0) _buildSwipeIndicator(),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (swipeProgress > 0.1) {
      final alpha = (swipeProgress.clamp(0.0, 1.0) * 255).round();
      return AppColors.nta.withAlpha(alpha);
    } else if (swipeProgress < -0.1) {
      final alpha = ((-swipeProgress).clamp(0.0, 1.0) * 255).round();
      return AppColors.yta.withAlpha(alpha);
    }
    return AppColors.white10;
  }

  Widget _buildSwipeHints() {
    final hintAlpha = (0.6 * 255).round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: AppColors.yta.withAlpha(hintAlpha),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              'YTA',
              style: TextStyle(
                color: AppColors.yta.withAlpha(hintAlpha),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              'NTA',
              style: TextStyle(
                color: AppColors.nta.withAlpha(hintAlpha),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.nta.withAlpha(hintAlpha),
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
    final color = isRight ? AppColors.nta : AppColors.yta;

    return Positioned(
      top: 20,
      left: isRight ? null : 20,
      right: isRight ? 20 : null,
      child: Transform.rotate(
        angle: isRight ? 0.2 : -0.2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withAlpha((alpha * 0.9).round()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.white50,
              width: 2,
            ),
          ),
          child: Text(
            isRight ? 'NTA' : 'YTA',
            style: TextStyle(
              color: AppColors.textPrimary.withAlpha(alpha),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
