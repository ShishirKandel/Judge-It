import 'package:flutter/services.dart';

/// Service for providing haptic feedback on user actions.
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  /// Light impact feedback (for swipe start)
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact feedback (for swipe completion)
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback (for significant events like badge unlock)
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click (for UI selections)
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Success feedback pattern (for agreeing with majority)
  Future<void> successFeedback() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Badge unlock celebration pattern
  Future<void> badgeUnlockFeedback() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }
}
