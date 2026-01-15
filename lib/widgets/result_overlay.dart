import 'package:flutter/material.dart';
import '../models/story.dart';
import '../providers/swipe_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'confetti_overlay.dart';
import 'avatar_widget.dart';

/// Overlay widget showing vote results after a swipe.
///
/// Design: Dramatic verdict reveal - performance optimized.
/// Displays the user's choice, agreement percentage, and avatar reaction.
/// No continuous animations for better performance.
class ResultOverlay extends StatefulWidget {
  final VoteType voteType;
  final double agreementPercentage;
  final bool agreedWithMajority;
  final String? storyId;
  final VoidCallback onDismiss;

  const ResultOverlay({
    super.key,
    required this.voteType,
    required this.agreementPercentage,
    required this.agreedWithMajority,
    this.storyId,
    required this.onDismiss,
  });

  @override
  State<ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<ResultOverlay>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late double _currentPercentage;
  int? _totalVotes;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _percentageAnimation;

  @override
  void initState() {
    super.initState();
    _currentPercentage = widget.agreementPercentage;

    // Single controller for all entrance animations
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    _percentageAnimation = Tween<double>(begin: 0, end: _currentPercentage).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getAvatarReaction() {
    if (_currentPercentage > 0.6) {
      return 'happy';
    } else if (_currentPercentage < 0.4) {
      return 'sad';
    } else {
      return 'neutral';
    }
  }

  String _getReactionMessage() {
    if (_currentPercentage > 0.7) {
      return 'Great minds think alike!';
    } else if (_currentPercentage > 0.5) {
      return 'You\'re with the majority!';
    } else if (_currentPercentage > 0.4) {
      return 'A close call!';
    } else {
      return 'Bold judgment!';
    }
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isNta = widget.voteType == VoteType.nta;
    final color = isNta ? AppTheme.nta : AppTheme.yta;
    final label = isNta ? 'Not the A**hole' : "You're the A**hole";
    final shortLabel = isNta ? 'NTA' : 'YTA';

    return ConfettiOverlay(
      showConfetti: widget.agreedWithMajority,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          color: Colors.black.withAlpha(isDark ? 220 : 200),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: color.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Verdict badge - static
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        shortLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Full label
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Avatar reaction
                    AvatarWidget(reaction: _getAvatarReaction(), size: 70),
                    const SizedBox(height: 10),

                    // Reaction message
                    Text(
                      _getReactionMessage(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Animated percentage display
                    AnimatedBuilder(
                      animation: _percentageAnimation,
                      builder: (context, child) {
                        final percent = (_percentageAnimation.value * 100).toStringAsFixed(0);
                        return Column(
                          children: [
                            Text(
                              '$percent%',
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'agreed with you',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withAlpha(200),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Total votes
                    if (_totalVotes != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        '$_totalVotes total votes',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Continue hint
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we have a storyId, use StreamBuilder for realtime updates
    if (widget.storyId != null) {
      return StreamBuilder<Story?>(
        stream: _firestoreService.watchStory(widget.storyId!),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final story = snapshot.data!;
            // Update percentage based on user's vote type
            final newPercentage = widget.voteType == VoteType.nta
                ? story.ntaPercentage
                : story.ytaPercentage;

            // Only update if changed significantly
            if ((newPercentage - _currentPercentage).abs() > 0.001) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _currentPercentage = newPercentage;
                    _totalVotes = story.totalVotes;
                  });
                }
              });
            }
          }
          return _buildContent(context);
        },
      );
    }

    // No storyId, use static display
    return _buildContent(context);
  }
}
