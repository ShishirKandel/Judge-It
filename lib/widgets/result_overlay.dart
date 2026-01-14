import 'package:flutter/material.dart';
import '../models/story.dart';
import '../providers/swipe_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'confetti_overlay.dart';
import 'avatar_widget.dart';

/// Overlay widget showing vote results after a swipe.
///
/// Displays the user's choice, agreement percentage, mascot reaction, and confetti.
/// Supports realtime vote count updates via Firestore listener.
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

class _ResultOverlayState extends State<ResultOverlay> {
  final FirestoreService _firestoreService = FirestoreService();
  late double _currentPercentage;
  int? _totalVotes;

  @override
  void initState() {
    super.initState();
    _currentPercentage = widget.agreementPercentage;
  }

  /// Determine avatar reaction type based on agreement percentage
  String _getAvatarReaction() {
    if (_currentPercentage > 0.6) {
      return 'happy';
    } else if (_currentPercentage < 0.4) {
      return 'sad';
    } else {
      return 'neutral';
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
    final percentage = (_currentPercentage * 100).toStringAsFixed(0);

    return ConfettiOverlay(
      showConfetti: widget.agreedWithMajority,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          color: isDark
              ? Colors.black.withAlpha(220)
              : colorScheme.scrim.withAlpha(200),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            color.withAlpha(60),
                            color.withAlpha(20),
                          ]
                        : [
                            color.withAlpha(40),
                            color.withAlpha(15),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: color.withAlpha(isDark ? 140 : 100),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(isDark ? 80 : 60),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge with short label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(100),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        shortLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full label
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Animated avatar reaction (replaces JudgeMascot)
                    AvatarWidget(reaction: _getAvatarReaction(), size: 80),
                    const SizedBox(height: 24),

                    // Percentage display
                    Text(
                      '$percentage%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'agreed with you',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withAlpha(220),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Continue hint
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(15)
                            : colorScheme.surfaceContainerHighest.withAlpha(150),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 16,
                            color: isDark
                                ? Colors.white.withAlpha(120)
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tap anywhere to continue',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.white.withAlpha(120)
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Total votes indicator (if available)
                    if (_totalVotes != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: 14,
                            color: isDark
                                ? Colors.white.withAlpha(100)
                                : colorScheme.onSurfaceVariant.withAlpha(150),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_totalVotes total votes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.white.withAlpha(100)
                                  : colorScheme.onSurfaceVariant.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ],
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
