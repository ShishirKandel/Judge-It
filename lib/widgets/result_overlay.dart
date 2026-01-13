import 'package:flutter/material.dart';
import '../providers/swipe_provider.dart';
import '../theme/app_colors.dart';

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
    final color = isNta ? AppColors.nta : AppColors.yta;
    final label = isNta ? 'Not the A**hole' : "You're the A**hole";
    final shortLabel = isNta ? 'NTA' : 'YTA';
    final percentage = (agreementPercentage * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: AppColors.black85,
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
                    color.withAlpha(77),
                    color.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withAlpha(128),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(77),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: color,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'agreed with you',
                    style: TextStyle(
                      color: AppColors.white80,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Tap anywhere to continue',
                    style: TextStyle(
                      color: AppColors.white50,
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
