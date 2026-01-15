import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../theme/app_colors.dart';

/// Badge display widget with progress tracking.
///
/// Design: Collectible badge aesthetic with elegant locked/unlocked states.
/// Shows earned status with progress bar for locked badges.
/// Optimized for performance - no continuous animations.
class BadgeCard extends StatelessWidget {
  final AppBadge badge;
  final bool isEarned;
  final double progress; // 0.0 to 1.0

  const BadgeCard({
    super.key,
    required this.badge,
    required this.isEarned,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEarned
            ? (isDark ? AppColors.gold.withAlpha(20) : AppColors.gold.withAlpha(15))
            : (isDark ? colorScheme.surfaceContainerHigh : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned
              ? AppColors.gold.withAlpha(80)
              : colorScheme.outlineVariant.withAlpha(50),
          width: isEarned ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge icon container - simplified
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isEarned
                  ? AppColors.gold.withAlpha(30)
                  : colorScheme.surfaceContainerHighest.withAlpha(100),
              shape: BoxShape.circle,
              border: Border.all(
                color: isEarned
                    ? AppColors.gold.withAlpha(60)
                    : colorScheme.outlineVariant.withAlpha(40),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 22,
                  color: isEarned ? null : Colors.grey.withAlpha(130),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Badge name
          Text(
            badge.name,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isEarned
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant.withAlpha(180),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Progress or earned indicator
          if (!isEarned) ...[
            // Progress bar - simplified
            SizedBox(
              height: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withAlpha(160),
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ] else ...[
            // Earned indicator - simplified
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.gold,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'Earned',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge unlock celebration widget - performance optimized
class BadgeUnlockCelebration extends StatefulWidget {
  final AppBadge badge;
  final VoidCallback onDismiss;

  const BadgeUnlockCelebration({
    super.key,
    required this.badge,
    required this.onDismiss,
  });

  @override
  State<BadgeUnlockCelebration> createState() => _BadgeUnlockCelebrationState();
}

class _BadgeUnlockCelebrationState extends State<BadgeUnlockCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Single scale entrance animation - no continuous animations
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withAlpha(200),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHigh
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.gold,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.gold,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'NEW BADGE',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Badge icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.badge.icon,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Badge name
                  Text(
                    widget.badge.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Badge description
                  Text(
                    widget.badge.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Tap to continue hint
                  Text(
                    'Tap to continue',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withAlpha(140),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
