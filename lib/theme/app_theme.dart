import 'package:flutter/material.dart';

/// Centralized theme configuration for the Judge It app.
///
/// Design Direction: "Modern Courtroom Drama"
/// A bold, theatrical aesthetic combining judicial gravitas with social media energy.
/// Deep rich backgrounds, judicial gold accents, and dramatic verdict colors.
class AppTheme {
  AppTheme._();

  // ============================================
  // CORE COLORS - The Judicial Palette
  // ============================================

  /// Judicial Gold - The core brand accent
  static const Color _judicialGold = Color(0xFFD4AF37);
  static const Color _judicialGoldLight = Color(0xFFE8C547);
  static const Color _judicialGoldDark = Color(0xFFB8962E);

  /// Deep Slate - Dark mode foundation
  static const Color _deepSlate = Color(0xFF0A0E17);
  static const Color _darkSurface = Color(0xFF121820);
  static const Color _elevatedSurface = Color(0xFF1A222D);
  static const Color _highlightSurface = Color(0xFF242E3D);

  /// Light mode foundations
  static const Color _ivoryWhite = Color(0xFFFAF8F5);
  static const Color _warmWhite = Color(0xFFF5F2ED);
  static const Color _softCream = Color(0xFFEDE8E0);

  /// NTA (Not the A**hole) - Verdict Green with gold undertones
  static const Color _ntaColor = Color(0xFF10B981);
  static const Color _ntaGlow = Color(0xFF34D399);

  /// YTA (You're the A**hole) - Verdict Red
  static const Color _ytaColor = Color(0xFFEF4444);
  static const Color _ytaGlow = Color(0xFFF87171);

  /// Skip/Neutral - Muted blue
  static const Color _skipColor = Color(0xFF6366F1);

  /// Public color accessors
  static const Color nta = _ntaColor;
  static const Color yta = _ytaColor;
  static const Color skip = _skipColor;
  static const Color gold = _judicialGold;
  static const Color goldLight = _judicialGoldLight;

  // ============================================
  // LIGHT THEME - "The Ivory Court"
  // ============================================
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _judicialGold,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFF3D6),
      onPrimaryContainer: _judicialGoldDark,
      secondary: const Color(0xFF5D5C52),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE2E0D4),
      onSecondaryContainer: const Color(0xFF1A1C16),
      tertiary: const Color(0xFF3B665A),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFBDECDC),
      onTertiaryContainer: const Color(0xFF002118),
      error: _ytaColor,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: _ivoryWhite,
      onSurface: const Color(0xFF1C1B18),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: _warmWhite,
      surfaceContainer: _softCream,
      surfaceContainerHigh: const Color(0xFFE5E0D8),
      surfaceContainerHighest: const Color(0xFFDFDAD2),
      onSurfaceVariant: const Color(0xFF4A4740),
      outline: const Color(0xFF7B7870),
      outlineVariant: const Color(0xFFCBC7BD),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFF313029),
      onInverseSurface: const Color(0xFFF4F0E7),
      inversePrimary: _judicialGoldLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar - Clean and authoritative
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),

      // Card theme - Elegant with subtle shadows
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withAlpha(30),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _judicialGold,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Filled button theme - Primary CTA
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _judicialGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _judicialGold,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // Text theme - Strong hierarchy
      textTheme: _buildTextTheme(colorScheme),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(120),
        thickness: 1,
        space: 1,
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _judicialGold,
        circularTrackColor: colorScheme.surfaceContainerHighest,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _judicialGold;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _judicialGold.withAlpha(80);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }

  // ============================================
  // DARK THEME - "The Midnight Court"
  // ============================================
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _judicialGoldLight,
      onPrimary: const Color(0xFF3D2E00),
      primaryContainer: const Color(0xFF584400),
      onPrimaryContainer: const Color(0xFFFFE08B),
      secondary: const Color(0xFFC9C6B8),
      onSecondary: const Color(0xFF313027),
      secondaryContainer: const Color(0xFF48473C),
      onSecondaryContainer: const Color(0xFFE5E2D4),
      tertiary: const Color(0xFFA1D0C0),
      onTertiary: const Color(0xFF05372C),
      tertiaryContainer: const Color(0xFF224E42),
      onTertiaryContainer: const Color(0xFFBDECDC),
      error: _ytaGlow,
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: _deepSlate,
      onSurface: const Color(0xFFE7E3DA),
      surfaceContainerLowest: const Color(0xFF060A11),
      surfaceContainerLow: _darkSurface,
      surfaceContainer: _elevatedSurface,
      surfaceContainerHigh: _highlightSurface,
      surfaceContainerHighest: const Color(0xFF2E3847),
      onSurfaceVariant: const Color(0xFFCBC7BD),
      outline: const Color(0xFF959289),
      outlineVariant: const Color(0xFF4A4740),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFFE7E3DA),
      onInverseSurface: const Color(0xFF313029),
      inversePrimary: _judicialGoldDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar theme - Dark and dramatic
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),

      // Card theme - Elevated glass effect
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withAlpha(60),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: colorScheme.surfaceContainerLow,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _judicialGoldLight,
          foregroundColor: const Color(0xFF3D2E00),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _judicialGoldLight,
          foregroundColor: const Color(0xFF3D2E00),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _judicialGoldLight,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // Text theme
      textTheme: _buildTextTheme(colorScheme),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(80),
        thickness: 1,
        space: 1,
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _judicialGoldLight,
        circularTrackColor: colorScheme.surfaceContainerHighest,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _judicialGoldLight;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _judicialGoldLight.withAlpha(60);
          }
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  /// Builds a consistent text theme with strong hierarchy
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles - For big dramatic moments
      displayLarge: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: colorScheme.onSurface,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: 0,
        height: 1.2,
      ),

      // Headline styles - Section headers
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: 0.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: 0.1,
      ),

      // Title styles - Card titles, list items
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.1,
      ),

      // Body styles - Story content
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: 1.65,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        height: 1.55,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        height: 1.45,
        letterSpacing: 0.3,
      ),

      // Label styles - Buttons, chips, badges
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Extension for easier access to vote-specific colors
extension VoteColorsExtension on ColorScheme {
  /// NTA (Not the A**hole) color
  Color get nta => AppTheme.nta;

  /// YTA (You're the A**hole) color
  Color get yta => AppTheme.yta;

  /// Skip color
  Color get skip => AppTheme.skip;

  /// Judicial gold accent
  Color get gold => brightness == Brightness.dark
      ? AppTheme.goldLight
      : AppTheme.gold;
}
