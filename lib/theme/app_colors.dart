import 'package:flutter/material.dart';

/// App color constants for consistent theming.
///
/// Design Direction: "Modern Courtroom Drama"
/// Rich, dramatic colors with judicial gold accents.
abstract class AppColors {
  // ============================================
  // DARK THEME COLORS - "The Midnight Court"
  // ============================================

  /// Deep slate background - the foundation
  static const Color background = Color(0xFF0A0E17);

  /// Elevated surfaces with subtle depth
  static const Color surface = Color(0xFF121820);
  static const Color surfaceElevated = Color(0xFF1A222D);
  static const Color surfaceHighlight = Color(0xFF242E3D);

  // ============================================
  // LIGHT THEME COLORS - "The Ivory Court"
  // ============================================

  static const Color backgroundLight = Color(0xFFFAF8F5);
  static const Color surfaceLight = Color(0xFFF5F2ED);
  static const Color surfaceElevatedLight = Color(0xFFEDE8E0);

  // ============================================
  // BRAND COLORS - The Judicial Palette
  // ============================================

  /// Judicial Gold - Primary brand color
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8C547);
  static const Color goldDark = Color(0xFFB8962E);
  static const Color goldMuted = Color(0xFF9A8530);

  // ============================================
  // VERDICT COLORS
  // ============================================

  /// NTA (Not the A**hole) - Emerald verdict
  static const Color nta = Color(0xFF10B981);
  static const Color ntaGlow = Color(0xFF34D399);
  static const Color ntaDark = Color(0xFF059669);

  /// YTA (You're the A**hole) - Crimson verdict
  static const Color yta = Color(0xFFEF4444);
  static const Color ytaGlow = Color(0xFFF87171);
  static const Color ytaDark = Color(0xFFDC2626);

  /// Skip - Indigo action
  static const Color skip = Color(0xFF6366F1);
  static const Color skipGlow = Color(0xFF818CF8);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Dark theme text
  static const Color textPrimary = Color(0xFFE7E3DA);
  static const Color textSecondary = Color(0xFFCBC7BD);
  static const Color textMuted = Color(0xFF959289);

  /// Light theme text
  static const Color textPrimaryLight = Color(0xFF1C1B18);
  static const Color textSecondaryLight = Color(0xFF4A4740);
  static const Color textMutedLight = Color(0xFF7B7870);

  // ============================================
  // GRADIENT PRESETS
  // ============================================

  /// Gold shimmer gradient
  static const List<Color> goldGradient = [
    Color(0xFFE8C547),
    Color(0xFFD4AF37),
    Color(0xFFB8962E),
  ];

  /// NTA verdict gradient
  static const List<Color> ntaGradient = [
    Color(0xFF34D399),
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  /// YTA verdict gradient
  static const List<Color> ytaGradient = [
    Color(0xFFF87171),
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];

  /// Dark surface gradient
  static const List<Color> darkSurfaceGradient = [
    Color(0xFF1A222D),
    Color(0xFF121820),
    Color(0xFF0A0E17),
  ];

  /// Light surface gradient
  static const List<Color> lightSurfaceGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFFAF8F5),
    Color(0xFFF5F2ED),
  ];

  // ============================================
  // OPACITY HELPERS
  // ============================================

  /// White with various opacities (for dark theme overlays)
  static Color white5 = Colors.white.withAlpha(13);
  static Color white10 = Colors.white.withAlpha(26);
  static Color white15 = Colors.white.withAlpha(38);
  static Color white20 = Colors.white.withAlpha(51);
  static Color white30 = Colors.white.withAlpha(77);
  static Color white40 = Colors.white.withAlpha(102);
  static Color white50 = Colors.white.withAlpha(128);
  static Color white60 = Colors.white.withAlpha(153);
  static Color white70 = Colors.white.withAlpha(179);
  static Color white80 = Colors.white.withAlpha(204);
  static Color white90 = Colors.white.withAlpha(230);

  /// Black with various opacities (for light theme overlays)
  static Color black5 = Colors.black.withAlpha(13);
  static Color black10 = Colors.black.withAlpha(26);
  static Color black15 = Colors.black.withAlpha(38);
  static Color black20 = Colors.black.withAlpha(51);
  static Color black30 = Colors.black.withAlpha(77);
  static Color black40 = Colors.black.withAlpha(102);
  static Color black50 = Colors.black.withAlpha(128);
  static Color black60 = Colors.black.withAlpha(153);
  static Color black70 = Colors.black.withAlpha(179);
  static Color black85 = Colors.black.withAlpha(217);

  // ============================================
  // GLOW & SHADOW COLORS
  // ============================================

  /// Gold glow for buttons and accents
  static Color goldGlow = gold.withAlpha(100);
  static Color goldShadow = gold.withAlpha(60);

  /// Verdict glows
  static Color ntaGlowColor = nta.withAlpha(120);
  static Color ytaGlowColor = yta.withAlpha(120);

  // ============================================
  // SPECIAL EFFECTS
  // ============================================

  /// Streak fire color
  static const Color streakFire = Color(0xFFF97316);
  static const Color streakFireGlow = Color(0xFFFB923C);

  /// Celebration confetti colors
  static const List<Color> confettiColors = [
    Color(0xFFD4AF37), // Gold
    Color(0xFF10B981), // Green
    Color(0xFF6366F1), // Indigo
    Color(0xFFF97316), // Orange
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];
}

/// Extension methods for color manipulation
extension ColorExtensions on Color {
  /// Create a lighter version of the color
  Color lighter([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Create a darker version of the color
  Color darker([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Create a more saturated version
  Color saturated([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withSaturation((hsl.saturation + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Create a desaturated version
  Color desaturated([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withSaturation((hsl.saturation - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
