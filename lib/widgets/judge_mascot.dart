import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

/// Types of mascot reactions based on voting outcome.
enum MascotReaction {
  /// User agreed with majority (>60%)
  happy,

  /// Close call (40-60%)
  neutral,

  /// User disagreed with majority (<40%)
  surprised,
}

/// Mascot widget with reaction expressions - performance optimized.
///
/// Design: Friendly judge mascot with simple entrance animation.
/// No continuous animations for better performance.
class JudgeMascot extends StatefulWidget {
  final MascotReaction reaction;
  final double size;
  final bool showMessage;

  const JudgeMascot({
    super.key,
    required this.reaction,
    this.size = 100,
    this.showMessage = true,
  });

  @override
  State<JudgeMascot> createState() => _JudgeMascotState();
}

class _JudgeMascotState extends State<JudgeMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Single bounce entrance - no continuous animations
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutBack,
    );

    _bounceController.forward();
  }

  @override
  void didUpdateWidget(JudgeMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reaction != widget.reaction) {
      _bounceController.reset();
      _bounceController.forward();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.reaction) {
      case MascotReaction.happy:
        return AppTheme.nta;
      case MascotReaction.surprised:
        return AppTheme.skip;
      case MascotReaction.neutral:
        return AppColors.gold;
    }
  }

  String get _emoji {
    switch (widget.reaction) {
      case MascotReaction.happy:
        return '🎉';
      case MascotReaction.surprised:
        return '😮';
      case MascotReaction.neutral:
        return '🤔';
    }
  }

  String get _message {
    switch (widget.reaction) {
      case MascotReaction.happy:
        return 'Great minds think alike!';
      case MascotReaction.neutral:
        return 'A close call!';
      case MascotReaction.surprised:
        return 'Bold take!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main mascot container
        ScaleTransition(
          scale: _bounceAnimation,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: _accentColor.withAlpha(150),
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                // Main emoji
                Center(
                  child: Text(
                    _emoji,
                    style: TextStyle(fontSize: widget.size * 0.45),
                  ),
                ),

                // Judge gavel badge
                Positioned(
                  bottom: widget.size * 0.05,
                  right: widget.size * 0.05,
                  child: Container(
                    width: widget.size * 0.28,
                    height: widget.size * 0.28,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.gavel_rounded,
                      color: Colors.white,
                      size: widget.size * 0.14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Message
        if (widget.showMessage) ...[
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _bounceAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _accentColor.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Mini mascot for inline use - simplified
class MiniJudgeMascot extends StatelessWidget {
  final MascotReaction reaction;
  final double size;

  const MiniJudgeMascot({
    super.key,
    required this.reaction,
    this.size = 40,
  });

  String get _emoji {
    switch (reaction) {
      case MascotReaction.happy:
        return '🎉';
      case MascotReaction.surprised:
        return '😮';
      case MascotReaction.neutral:
        return '🤔';
    }
  }

  Color get _borderColor {
    switch (reaction) {
      case MascotReaction.happy:
        return AppTheme.nta;
      case MascotReaction.surprised:
        return AppTheme.skip;
      case MascotReaction.neutral:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: _borderColor.withAlpha(120),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          _emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
