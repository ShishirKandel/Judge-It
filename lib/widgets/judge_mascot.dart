import 'package:flutter/material.dart';

/// Types of mascot reactions based on voting outcome.
enum MascotReaction {
  /// User agreed with majority (>60%)
  happy,

  /// Close call (40-60%)
  neutral,

  /// User disagreed with majority (<40%)
  surprised,
}

/// Animated judge mascot widget that reacts to voting results.
///
/// Shows different expressions based on whether user agreed with majority.
class JudgeMascot extends StatefulWidget {
  final MascotReaction reaction;

  const JudgeMascot({
    super.key,
    required this.reaction,
  });

  @override
  State<JudgeMascot> createState() => _JudgeMascotState();
}

class _JudgeMascotState extends State<JudgeMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEmoji() {
    switch (widget.reaction) {
      case MascotReaction.happy:
        return '🎉';
      case MascotReaction.neutral:
        return '🤔';
      case MascotReaction.surprised:
        return '😮';
    }
  }

  String _getMessage() {
    switch (widget.reaction) {
      case MascotReaction.happy:
        return 'Great minds think alike!';
      case MascotReaction.neutral:
        return 'A close call!';
      case MascotReaction.surprised:
        return 'Bold take!';
    }
  }

  Color _getGlowColor() {
    switch (widget.reaction) {
      case MascotReaction.happy:
        return Colors.green;
      case MascotReaction.neutral:
        return Colors.orange;
      case MascotReaction.surprised:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji with animation
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(
                  0,
                  -10 * (1 - _bounceAnimation.value),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getGlowColor().withAlpha(60),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    _getEmoji(),
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Message with fade in
            Opacity(
              opacity: _bounceAnimation.value.clamp(0.0, 1.0),
              child: Text(
                _getMessage(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? Colors.white.withAlpha(180)
                      : theme.colorScheme.onSurface.withAlpha(180),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
