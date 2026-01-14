import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Animated avatar widget that displays different reactions.
/// 
/// Uses Flutter animations for smooth character reactions.
/// Supports three avatar types: classic (emoji), boy, and girl.
class AvatarWidget extends StatefulWidget {
  /// Reaction type: 'happy', 'sad', 'neutral'
  final String reaction;
  
  /// Size of the avatar
  final double size;
  
  /// Whether to play the animation
  final bool animate;

  const AvatarWidget({
    super.key,
    required this.reaction,
    this.size = 100,
    this.animate = true,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    if (widget.animate) {
      _bounceController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return AnimatedBuilder(
          animation: Listenable.merge([_bounceAnimation, _pulseAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value * _pulseAnimation.value,
              child: _buildAvatar(settings.avatarType),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatar(AvatarType type) {
    switch (type) {
      case AvatarType.boy:
        return _BoyAvatar(reaction: widget.reaction, size: widget.size);
      case AvatarType.girl:
        return _GirlAvatar(reaction: widget.reaction, size: widget.size);
      case AvatarType.classic:
        return _ClassicAvatar(reaction: widget.reaction, size: widget.size);
    }
  }
}

/// Classic emoji-based avatar
class _ClassicAvatar extends StatelessWidget {
  final String reaction;
  final double size;

  const _ClassicAvatar({required this.reaction, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      _getEmoji(),
      style: TextStyle(fontSize: size * 0.8),
    );
  }

  String _getEmoji() {
    switch (reaction) {
      case 'happy':
        return '🎉';
      case 'sad':
        return '😮';
      case 'neutral':
      default:
        return '🤔';
    }
  }
}

/// Animated boy character avatar
class _BoyAvatar extends StatelessWidget {
  final String reaction;
  final double size;

  const _BoyAvatar({required this.reaction, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(100),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Face
          Positioned(
            top: size * 0.25,
            child: _buildFace(),
          ),
          // Hair
          Positioned(
            top: size * 0.1,
            child: _buildHair(),
          ),
        ],
      ),
    );
  }

  Widget _buildFace() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eyes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEye(),
            SizedBox(width: size * 0.15),
            _buildEye(),
          ],
        ),
        SizedBox(height: size * 0.08),
        // Mouth
        _buildMouth(),
      ],
    );
  }

  Widget _buildEye() {
    final eyeSize = size * 0.12;
    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: eyeSize * 0.5,
          height: eyeSize * 0.5,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildMouth() {
    final mouthWidth = size * 0.25;
    final mouthHeight = size * 0.12;
    
    switch (reaction) {
      case 'happy':
        return Container(
          width: mouthWidth,
          height: mouthHeight,
          decoration: BoxDecoration(
            color: Colors.pink.shade300,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(mouthHeight),
              bottomRight: Radius.circular(mouthHeight),
            ),
          ),
        );
      case 'sad':
        return Container(
          width: mouthWidth,
          height: mouthHeight * 0.5,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.pink.shade300, width: 3),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(mouthHeight),
              topRight: Radius.circular(mouthHeight),
            ),
          ),
        );
      default:
        return Container(
          width: mouthWidth * 0.6,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.pink.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
    }
  }

  Widget _buildHair() {
    return Container(
      width: size * 0.5,
      height: size * 0.2,
      decoration: BoxDecoration(
        color: Colors.brown.shade700,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size * 0.25),
          topRight: Radius.circular(size * 0.25),
        ),
      ),
    );
  }
}

/// Animated girl character avatar
class _GirlAvatar extends StatelessWidget {
  final String reaction;
  final double size;

  const _GirlAvatar({required this.reaction, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.pink.shade200,
            Colors.pink.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withAlpha(100),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Face
          Positioned(
            top: size * 0.28,
            child: _buildFace(),
          ),
          // Hair with bows
          Positioned(
            top: size * 0.05,
            left: size * 0.1,
            child: _buildBow(),
          ),
          Positioned(
            top: size * 0.05,
            right: size * 0.1,
            child: _buildBow(),
          ),
          // Bangs
          Positioned(
            top: size * 0.12,
            child: _buildBangs(),
          ),
        ],
      ),
    );
  }

  Widget _buildFace() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Eyes with lashes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEye(),
            SizedBox(width: size * 0.12),
            _buildEye(),
          ],
        ),
        SizedBox(height: size * 0.02),
        // Blush
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBlush(),
            SizedBox(width: size * 0.2),
            _buildBlush(),
          ],
        ),
        SizedBox(height: size * 0.03),
        // Mouth
        _buildMouth(),
      ],
    );
  }

  Widget _buildEye() {
    final eyeSize = size * 0.11;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lashes
        Container(
          width: eyeSize * 1.2,
          height: 2,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 1),
        Container(
          width: eyeSize,
          height: eyeSize,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: eyeSize * 0.5,
              height: eyeSize * 0.5,
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlush() {
    return Container(
      width: size * 0.08,
      height: size * 0.04,
      decoration: BoxDecoration(
        color: Colors.pink.shade200.withAlpha(150),
        borderRadius: BorderRadius.circular(size * 0.02),
      ),
    );
  }

  Widget _buildMouth() {
    final mouthWidth = size * 0.2;
    final mouthHeight = size * 0.1;
    
    switch (reaction) {
      case 'happy':
        return Container(
          width: mouthWidth,
          height: mouthHeight,
          decoration: BoxDecoration(
            color: Colors.red.shade300,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(mouthHeight),
              bottomRight: Radius.circular(mouthHeight),
            ),
          ),
        );
      case 'sad':
        return Container(
          width: mouthWidth * 0.8,
          height: mouthHeight * 0.5,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.red.shade300, width: 2),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(mouthHeight),
              topRight: Radius.circular(mouthHeight),
            ),
          ),
        );
      default:
        return Container(
          width: mouthWidth * 0.5,
          height: 2,
          decoration: BoxDecoration(
            color: Colors.red.shade300,
            borderRadius: BorderRadius.circular(1),
          ),
        );
    }
  }

  Widget _buildBow() {
    return Container(
      width: size * 0.12,
      height: size * 0.08,
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(size * 0.02),
      ),
    );
  }

  Widget _buildBangs() {
    return Container(
      width: size * 0.4,
      height: size * 0.12,
      decoration: BoxDecoration(
        color: Colors.brown.shade600,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(size * 0.1),
          bottomRight: Radius.circular(size * 0.1),
        ),
      ),
    );
  }
}
