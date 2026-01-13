import 'package:flutter/material.dart';

/// App color constants for consistent theming.
abstract class AppColors {
  // Background colors
  static const Color background = Color(0xFF0D0D14);
  static const Color surface = Color(0xFF1E1E2E);
  static const Color surfaceLight = Color(0xFF2D2D44);

  // Primary colors
  static const Color primary = Colors.amber;
  static const Color primaryAccent = Colors.amberAccent;

  // Vote colors
  static const Color nta = Colors.green;
  static const Color yta = Colors.red;

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;

  // Opacity helpers (pre-calculated alpha values)
  static Color white10 = Colors.white.withAlpha(26);
  static Color white30 = Colors.white.withAlpha(77);
  static Color white50 = Colors.white.withAlpha(128);
  static Color white60 = Colors.white.withAlpha(153);
  static Color white80 = Colors.white.withAlpha(204);
  static Color white90 = Colors.white.withAlpha(230);

  static Color black30 = Colors.black.withAlpha(77);
  static Color black85 = Colors.black.withAlpha(217);
}
