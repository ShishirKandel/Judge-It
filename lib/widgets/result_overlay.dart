import 'package:flutter/material.dart';
import '../providers/swipe_provider.dart';

/// Overlay widget showing vote results after a swipe.
/// 
/// Displays the user's choice and the agreement percentage.
class ResultOverlay extends StatelessWidget {
  final VoteType voteType;
  final double agreementPercentage;
  final VoidCallback onDismiss;

  const ResultOverlay({
    super.key,
    required this.voteType,
    required this.agreementPercentage,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isNta = voteType == VoteType.nta;
    final color = isNta ? Colors.green : Colors.red;
    final label = isNta ? 'Not the A**hole' : "You're the A**hole";
    final shortLabel = isNta ? 'NTA' : 'YTA';
    final percentage = (agreementPercentage * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withAlpha(217), // 0.85 opacity
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
                  colors: [
                    color.withAlpha(77), // 0.3 opacity
                    color.withAlpha(26), // 0.1 opacity
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withAlpha(128), // 0.5 opacity
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(77), // 0.3 opacity
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vote badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      shortLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Full label
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Percentage
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$percentage%',
                          style: TextStyle(
                            color: color,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'agreed with you',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204), // 0.8 opacity
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tap to continue hint
                  Text(
                    'Tap anywhere to continue',
                    style: TextStyle(
                      color: Colors.white.withAlpha(128), // 0.5 opacity
                      fontSize: 14,
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
