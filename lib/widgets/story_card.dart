import 'package:flutter/material.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';

/// Card widget displaying a story for swiping.
///
/// Design: Elegant case file aesthetic with dramatic verdict stamps.
/// Shows title, body text, and optional top comment.
/// Optimized for performance - minimal shadows and effects.
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Simple solid color instead of gradient for performance
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Dynamic border based on swipe
        border: Border.all(
          color: _getBorderColor(colorScheme, isDark),
          width: 2,
        ),
        // Single simple shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with case number styling
                  _buildHeader(theme, colorScheme, isDark),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    story.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Simple divider
                  Divider(
                    color: colorScheme.outlineVariant.withAlpha(80),
                    height: 1,
                  ),
                  const SizedBox(height: 12),

                  // Story body - removed ShaderMask for performance
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.body,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.7,
                                color: colorScheme.onSurface.withAlpha(220),
                              ),
                            ),
                            // Top comment section
                            if (story.hasTopComment) ...[
                              const SizedBox(height: 20),
                              _buildTopComment(theme, colorScheme, isDark),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Swipe hints
                  const SizedBox(height: 12),
                  _buildSwipeHints(theme, colorScheme, isDark),
                ],
              ),
            ),

            // Verdict stamp overlay during swipe
            if (swipeProgress.abs() > 0.15) _buildVerdictStamp(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return Row(
      children: [
        // Case badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(isDark ? 30 : 20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.primary.withAlpha(60),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_rounded,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'CASE FILE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Scroll indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe_vertical_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant.withAlpha(180),
              ),
              const SizedBox(width: 4),
              Text(
                'Scroll to read',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withAlpha(180),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopComment(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withAlpha(80)
            : colorScheme.surfaceContainerHighest.withAlpha(150),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withAlpha(40),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.forum_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Top Comment',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            story.topComment!,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurface.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHints(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withAlpha(80)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(60),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHintItem(
            icon: Icons.arrow_back_rounded,
            label: 'YTA',
            color: AppTheme.yta,
            isLeft: true,
            isActive: swipeProgress < -0.1,
          ),
          Container(
            height: 24,
            width: 1,
            color: colorScheme.outlineVariant.withAlpha(80),
          ),
          _buildHintItem(
            icon: Icons.arrow_upward_rounded,
            label: 'SKIP',
            color: AppTheme.skip,
            isLeft: false,
            isActive: false,
          ),
          Container(
            height: 24,
            width: 1,
            color: colorScheme.outlineVariant.withAlpha(80),
          ),
          _buildHintItem(
            icon: Icons.arrow_forward_rounded,
            label: 'NTA',
            color: AppTheme.nta,
            isLeft: false,
            isActive: swipeProgress > 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildHintItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isLeft,
    required bool isActive,
  }) {
    final alpha = isActive ? 255 : 150;
    final children = [
      Icon(
        icon,
        color: color.withAlpha(alpha),
        size: 18,
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          color: color.withAlpha(alpha),
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.8,
        ),
      ),
    ];

    return AnimatedScale(
      scale: isActive ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Row(
        children: isLeft ? children : children.reversed.toList(),
      ),
    );
  }

  Widget _buildVerdictStamp(bool isDark) {
    final isRight = swipeProgress > 0;
    final alpha = (swipeProgress.abs().clamp(0.0, 1.0) * 255).round();
    final color = isRight ? AppTheme.nta : AppTheme.yta;
    final label = isRight ? 'NTA' : 'YTA';

    return Positioned(
      top: 70,
      left: isRight ? null : 20,
      right: isRight ? 20 : null,
      child: Transform.rotate(
        angle: isRight ? 0.15 : -0.15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha((alpha * 0.85).round()),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withAlpha((alpha * 0.5).round()),
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(alpha),
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(ColorScheme colorScheme, bool isDark) {
    if (swipeProgress > 0.15) {
      final alpha = (swipeProgress.clamp(0.0, 1.0) * 200).round();
      return AppTheme.nta.withAlpha(alpha);
    } else if (swipeProgress < -0.15) {
      final alpha = ((-swipeProgress).clamp(0.0, 1.0) * 200).round();
      return AppTheme.yta.withAlpha(alpha);
    }
    return colorScheme.outlineVariant.withAlpha(isDark ? 40 : 60);
  }
}
