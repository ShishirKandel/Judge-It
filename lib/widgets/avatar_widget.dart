import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

/// Animated avatar widget with multiple types and reactions.
///
/// Design: Expressive character with entrance animation only.
/// Supports classic (emoji), boy, and girl avatar types.
/// Performance optimized - no continuous animations.
class AvatarWidget extends StatefulWidget {
  final String reaction; // 'happy', 'sad', 'neutral'
  final double size;
  final AvatarType? overrideType;
  final bool showGlow;

  const AvatarWidget({
    super.key,
    required this.reaction,
    this.size = 80,
    this.overrideType,
    this.showGlow = false, // Disabled by default for performance
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Single bounce entrance animation - no continuous animations
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
  void didUpdateWidget(AvatarWidget oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final avatarType = widget.overrideType ??
        context.select<SettingsProvider, AvatarType>((p) => p.avatarType);

    return ScaleTransition(
      scale: _bounceAnimation,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _buildAvatar(avatarType),
      ),
    );
  }

  Widget _buildAvatar(AvatarType type) {
    switch (type) {
      case AvatarType.classic:
        return _ClassicAvatar(
          reaction: widget.reaction,
          size: widget.size,
        );
      case AvatarType.boy:
        return _CharacterAvatar(
          reaction: widget.reaction,
          size: widget.size,
          isBoy: true,
        );
      case AvatarType.girl:
        return _CharacterAvatar(
          reaction: widget.reaction,
          size: widget.size,
          isBoy: false,
        );
    }
  }
}

/// Classic emoji-based avatar - performance optimized
class _ClassicAvatar extends StatelessWidget {
  final String reaction;
  final double size;

  const _ClassicAvatar({required this.reaction, required this.size});

  String get _emoji {
    switch (reaction) {
      case 'happy':
        return '😄';
      case 'sad':
        return '😢';
      case 'neutral':
      default:
        return '🤔';
    }
  }

  Color get _borderColor {
    switch (reaction) {
      case 'happy':
        return AppTheme.nta;
      case 'sad':
        return AppTheme.yta;
      case 'neutral':
      default:
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
        shape: BoxShape.circle,
        color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
        border: Border.all(
          color: _borderColor.withAlpha(150),
          width: 2.5,
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

/// Character-based avatar - performance optimized
class _CharacterAvatar extends StatelessWidget {
  final String reaction;
  final double size;
  final bool isBoy;

  const _CharacterAvatar({
    required this.reaction,
    required this.size,
    required this.isBoy,
  });

  Color get _skinColor => isBoy
      ? const Color(0xFFFFDBC4)
      : const Color(0xFFFFE4D6);

  Color get _hairColor => isBoy
      ? const Color(0xFF3D2914)
      : const Color(0xFF5D3A1A);

  Color get _borderColor {
    switch (reaction) {
      case 'happy':
        return AppTheme.nta;
      case 'sad':
        return AppTheme.yta;
      case 'neutral':
      default:
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
        shape: BoxShape.circle,
        color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
        border: Border.all(
          color: _borderColor.withAlpha(150),
          width: 2.5,
        ),
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Face base
            Center(
              child: Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: _skinColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Hair
            Positioned(
              top: size * 0.12,
              left: size * 0.18,
              right: size * 0.18,
              child: Container(
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: _hairColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size * 0.2),
                    topRight: Radius.circular(size * 0.2),
                  ),
                ),
              ),
            ),

            // Girl extras
            if (!isBoy) ...[
              Positioned(
                top: size * 0.28,
                left: size * 0.12,
                child: Container(
                  width: size * 0.08,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: _hairColor,
                    borderRadius: BorderRadius.circular(size * 0.04),
                  ),
                ),
              ),
              Positioned(
                top: size * 0.28,
                right: size * 0.12,
                child: Container(
                  width: size * 0.08,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: _hairColor,
                    borderRadius: BorderRadius.circular(size * 0.04),
                  ),
                ),
              ),
              Positioned(
                top: size * 0.1,
                right: size * 0.24,
                child: Container(
                  width: size * 0.1,
                  height: size * 0.06,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(size * 0.03),
                  ),
                ),
              ),
            ],

            // Eyes
            Positioned(
              top: size * 0.38,
              left: size * 0.3,
              child: _Eye(size: size * 0.1, reaction: reaction),
            ),
            Positioned(
              top: size * 0.38,
              right: size * 0.3,
              child: _Eye(size: size * 0.1, reaction: reaction),
            ),

            // Mouth
            Positioned(
              bottom: size * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: _Mouth(size: size * 0.2, reaction: reaction),
              ),
            ),

            // Blush for happy
            if (reaction == 'happy') ...[
              Positioned(
                top: size * 0.48,
                left: size * 0.2,
                child: Container(
                  width: size * 0.07,
                  height: size * 0.035,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9999).withAlpha(70),
                    borderRadius: BorderRadius.circular(size * 0.02),
                  ),
                ),
              ),
              Positioned(
                top: size * 0.48,
                right: size * 0.2,
                child: Container(
                  width: size * 0.07,
                  height: size * 0.035,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9999).withAlpha(70),
                    borderRadius: BorderRadius.circular(size * 0.02),
                  ),
                ),
              ),
            ],

            // Tear for sad
            if (reaction == 'sad')
              Positioned(
                top: size * 0.5,
                left: size * 0.33,
                child: Container(
                  width: size * 0.035,
                  height: size * 0.05,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.withAlpha(140),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(size * 0.015),
                      bottom: Radius.circular(size * 0.025),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Eye component - simplified
class _Eye extends StatelessWidget {
  final double size;
  final String reaction;

  const _Eye({required this.size, required this.reaction});

  @override
  Widget build(BuildContext context) {
    final isSad = reaction == 'sad';

    return Container(
      width: size,
      height: isSad ? size * 0.4 : size,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: isSad
            ? BorderRadius.vertical(bottom: Radius.circular(size * 0.5))
            : BorderRadius.circular(size * 0.5),
      ),
      child: !isSad
          ? Align(
              alignment: const Alignment(0.3, -0.3),
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

/// Mouth component - simplified
class _Mouth extends StatelessWidget {
  final double size;
  final String reaction;

  const _Mouth({required this.size, required this.reaction});

  @override
  Widget build(BuildContext context) {
    switch (reaction) {
      case 'happy':
        return Container(
          width: size,
          height: size * 0.45,
          decoration: BoxDecoration(
            color: const Color(0xFFE87B6D),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(size * 0.4),
            ),
          ),
        );

      case 'sad':
        return Container(
          width: size * 0.8,
          height: size * 0.25,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFD4645A),
                width: 3,
              ),
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(size * 0.4),
            ),
          ),
        );

      case 'neutral':
      default:
        return Container(
          width: size * 0.5,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFD4645A),
            borderRadius: BorderRadius.circular(2),
          ),
        );
    }
  }
}
