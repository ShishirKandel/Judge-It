import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

/// Confetti animation overlay displayed on agreement with majority.
///
/// Design: Celebratory burst effect with themed colors.
/// Multiple confetti sources for dramatic courtroom victory effect.
/// Features varied particle shapes and staggered timing.
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool showConfetti;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.showConfetti = false,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _centerController;
  late ConfettiController _leftController;
  late ConfettiController _rightController;
  late ConfettiController _bottomLeftController;
  late ConfettiController _bottomRightController;

  @override
  void initState() {
    super.initState();

    // Center burst - main celebration
    _centerController = ConfettiController(
      duration: const Duration(seconds: 4),
    );

    // Left corner burst
    _leftController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Right corner burst
    _rightController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Bottom left burst
    _bottomLeftController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Bottom right burst
    _bottomRightController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    if (widget.showConfetti) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _startConfetti();
    } else if (!widget.showConfetti && oldWidget.showConfetti) {
      _stopConfetti();
    }
  }

  void _startConfetti() {
    // Main burst immediately
    _centerController.play();

    // Staggered side bursts for dramatic effect
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _leftController.play();
    });
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) _rightController.play();
    });

    // Bottom bursts slightly later
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bottomLeftController.play();
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _bottomRightController.play();
    });
  }

  void _stopConfetti() {
    _centerController.stop();
    _leftController.stop();
    _rightController.stop();
    _bottomLeftController.stop();
    _bottomRightController.stop();
  }

  @override
  void dispose() {
    _centerController.dispose();
    _leftController.dispose();
    _rightController.dispose();
    _bottomLeftController.dispose();
    _bottomRightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,

        // Center top burst - main celebration
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _centerController,
            blastDirection: math.pi / 2, // Downward
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 25,
            minBlastForce: 12,
            emissionFrequency: 0.03,
            numberOfParticles: 40,
            gravity: 0.15,
            particleDrag: 0.04,
            colors: AppColors.confettiColors,
            createParticlePath: (size) => _createParticlePath(size),
            shouldLoop: false,
          ),
        ),

        // Top left diagonal burst
        Align(
          alignment: const Alignment(-0.85, -1.0),
          child: ConfettiWidget(
            confettiController: _leftController,
            blastDirection: math.pi / 3, // Diagonal down-right
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 22,
            minBlastForce: 10,
            emissionFrequency: 0.04,
            numberOfParticles: 25,
            gravity: 0.2,
            particleDrag: 0.04,
            colors: AppColors.confettiColors,
            createParticlePath: (size) => _createParticlePath(size),
            shouldLoop: false,
          ),
        ),

        // Top right diagonal burst
        Align(
          alignment: const Alignment(0.85, -1.0),
          child: ConfettiWidget(
            confettiController: _rightController,
            blastDirection: 2 * math.pi / 3, // Diagonal down-left
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 22,
            minBlastForce: 10,
            emissionFrequency: 0.04,
            numberOfParticles: 25,
            gravity: 0.2,
            particleDrag: 0.04,
            colors: AppColors.confettiColors,
            createParticlePath: (size) => _createParticlePath(size),
            shouldLoop: false,
          ),
        ),

        // Bottom left fountain burst
        Align(
          alignment: const Alignment(-0.7, 0.95),
          child: ConfettiWidget(
            confettiController: _bottomLeftController,
            blastDirection: -math.pi / 2.5, // Upward right
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 18,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 18,
            gravity: 0.3,
            particleDrag: 0.05,
            colors: AppColors.confettiColors,
            createParticlePath: (size) => _createParticlePath(size),
            shouldLoop: false,
          ),
        ),

        // Bottom right fountain burst
        Align(
          alignment: const Alignment(0.7, 0.95),
          child: ConfettiWidget(
            confettiController: _bottomRightController,
            blastDirection: -math.pi + math.pi / 2.5, // Upward left
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 18,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 18,
            gravity: 0.3,
            particleDrag: 0.05,
            colors: AppColors.confettiColors,
            createParticlePath: (size) => _createParticlePath(size),
            shouldLoop: false,
          ),
        ),
      ],
    );
  }

  /// Creates varied particle shapes for visual richness
  Path _createParticlePath(Size size) {
    final random = math.Random();
    final shapeType = random.nextInt(6);

    switch (shapeType) {
      case 0:
        // Rectangle confetti strip
        return Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));

      case 1:
        // Circle
        return Path()
          ..addOval(
              Rect.fromLTWH(0, 0, size.width * 0.85, size.height * 0.85));

      case 2:
        // Star
        return _createStarPath(size);

      case 3:
        // Diamond
        return Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();

      case 4:
        // Heart shape
        return _createHeartPath(size);

      default:
        // Rounded rectangle
        return Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width * 0.9, size.height * 0.6),
            Radius.circular(size.width * 0.15),
          ));
    }
  }

  /// Creates a 5-pointed star path
  Path _createStarPath(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4;
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  /// Creates a simple heart shape path
  Path _createHeartPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h * 0.3);

    // Left curve
    path.cubicTo(
      w * 0.15, h * 0.0,
      0, h * 0.4,
      w / 2, h,
    );

    // Right curve
    path.moveTo(w / 2, h * 0.3);
    path.cubicTo(
      w * 0.85, h * 0.0,
      w, h * 0.4,
      w / 2, h,
    );

    path.close();
    return path;
  }
}

/// Gold shimmer confetti for special achievements
class GoldConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool showConfetti;

  const GoldConfettiOverlay({
    super.key,
    required this.child,
    this.showConfetti = false,
  });

  @override
  State<GoldConfettiOverlay> createState() => _GoldConfettiOverlayState();
}

class _GoldConfettiOverlayState extends State<GoldConfettiOverlay> {
  late ConfettiController _controller;

  static const _goldColors = [
    Color(0xFFD4AF37),
    Color(0xFFFFD700),
    Color(0xFFF5DEB3),
    Color(0xFFDAA520),
    Color(0xFFB8860B),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    if (widget.showConfetti) {
      _controller.play();
    }
  }

  @override
  void didUpdateWidget(GoldConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _controller.play();
    } else if (!widget.showConfetti && oldWidget.showConfetti) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirection: math.pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 30,
            minBlastForce: 15,
            emissionFrequency: 0.02,
            numberOfParticles: 50,
            gravity: 0.1,
            particleDrag: 0.03,
            colors: _goldColors,
            createParticlePath: (size) {
              // Star-only particles for gold confetti
              return _createGoldStarPath(size);
            },
            shouldLoop: false,
          ),
        ),
      ],
    );
  }

  Path _createGoldStarPath(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 3;
    const points = 4; // 4-pointed sparkle star

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
}
