import 'package:flutter/material.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surfaceContainerLow,
                  colorScheme.surfaceContainerHigh,
                ]
              : [
                  colorScheme.surfaceContainerLowest,
                  colorScheme.surfaceContainerLow,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(100)
                : colorScheme.shadow.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          if (!isDark)
            BoxShadow(
              color: colorScheme.primary.withAlpha(10),
              blurRadius: 40,
              offset: const Offset(0, 5),
            ),
        ],
        border: Border.all(
          color: _getBorderColor(colorScheme, isDark),
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        colorScheme.outlineVariant.withAlpha(100),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.white.withAlpha(0),
                        ],
                        stops: const [0.0, 0.85, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.body,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.7,
                                color: colorScheme.onSurface.withAlpha(230),
                              ),
                            ),
                            // Top comment section
                            if (story.hasTopComment) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withAlpha(120),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outline.withAlpha(50),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Top Comment',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      story.topComment!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        height: 1.5,
                                        fontStyle: FontStyle.italic,
                                        color: colorScheme.onSurface.withAlpha(200),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwipeHints(theme, colorScheme),
              ],
            ),
          ),
          if (swipeProgress != 0) _buildSwipeIndicator(colorScheme, isDark),
        ],
      ),
    );
  }

  Color _getBorderColor(ColorScheme colorScheme, bool isDark) {
    if (swipeProgress > 0.1) {
      final alpha = (swipeProgress.clamp(0.0, 1.0) * 255).round();
      return AppTheme.nta.withAlpha(alpha);
    } else if (swipeProgress < -0.1) {
      final alpha = ((-swipeProgress).clamp(0.0, 1.0) * 255).round();
      return AppTheme.yta.withAlpha(alpha);
    }
    return isDark
        ? colorScheme.outlineVariant.withAlpha(50)
        : colorScheme.outlineVariant.withAlpha(80);
  }

  Widget _buildSwipeHints(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHintItem(
            icon: Icons.arrow_back_rounded,
            label: 'YTA',
            color: AppTheme.yta,
            isLeft: true,
          ),
          Container(
            width: 1,
            height: 24,
            color: colorScheme.outlineVariant.withAlpha(80),
          ),
          _buildHintItem(
            icon: Icons.arrow_forward_rounded,
            label: 'NTA',
            color: AppTheme.nta,
            isLeft: false,
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
  }) {
    final alpha = 180;
    final children = [
      Icon(
        icon,
        color: color.withAlpha(alpha),
        size: 20,
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          color: color.withAlpha(alpha),
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    ];

    return Row(
      children: isLeft ? children : children.reversed.toList(),
    );
  }

  Widget _buildSwipeIndicator(ColorScheme colorScheme, bool isDark) {
    final isRight = swipeProgress > 0;
    final alpha = (swipeProgress.abs().clamp(0.0, 1.0) * 255).round();
    final color = isRight ? AppTheme.nta : AppTheme.yta;

    return Positioned(
      top: 24,
      left: isRight ? null : 24,
      right: isRight ? 24 : null,
      child: Transform.rotate(
        angle: isRight ? 0.15 : -0.15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha((alpha * 0.95).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha((alpha * 0.5).round()),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha((alpha * 0.5).round()),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            isRight ? 'NTA' : 'YTA',
            style: TextStyle(
              color: Colors.white.withAlpha(alpha),
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
