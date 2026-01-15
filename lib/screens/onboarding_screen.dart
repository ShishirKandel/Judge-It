import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

/// Onboarding screen that explains the swipe gestures.
///
/// Design: Dramatic courtroom-inspired introduction with bold visuals.
/// Shows only on first app launch, then remembers completion.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  // Page configurations with dramatic courtroom theme
  static final List<OnboardingPageData> _pageData = [
    OnboardingPageData(
      icon: Icons.gavel_rounded,
      accentColor: AppColors.gold,
      title: 'Welcome to the Court',
      subtitle: 'Judge It',
      description: 'Read real stories and deliver your verdict.\nAre they the A**hole or not?',
      backgroundGradient: [
        const Color(0xFF1A1510),
        const Color(0xFF0A0E17),
      ],
    ),
    OnboardingPageData(
      icon: Icons.arrow_forward_rounded,
      accentColor: AppTheme.nta,
      title: 'Swipe Right',
      subtitle: 'NTA',
      description: 'Not the A**hole\n\nSwipe right if you think they did nothing wrong.',
      backgroundGradient: [
        const Color(0xFF0A1A14),
        const Color(0xFF0A0E17),
      ],
    ),
    OnboardingPageData(
      icon: Icons.arrow_back_rounded,
      accentColor: AppTheme.yta,
      title: 'Swipe Left',
      subtitle: 'YTA',
      description: "You're the A**hole\n\nSwipe left if you think they were in the wrong.",
      backgroundGradient: [
        const Color(0xFF1A0A0A),
        const Color(0xFF0A0E17),
      ],
    ),
    OnboardingPageData(
      icon: Icons.arrow_upward_rounded,
      accentColor: AppTheme.skip,
      title: 'Swipe Up',
      subtitle: 'SKIP',
      description: "Not sure?\n\nSwipe up to skip and move to the next case.",
      backgroundGradient: [
        const Color(0xFF0F0F1A),
        const Color(0xFF0A0E17),
      ],
    ),
    OnboardingPageData(
      icon: Icons.how_to_vote_rounded,
      accentColor: AppColors.gold,
      title: 'See the Verdict',
      subtitle: 'RESULTS',
      description: 'After voting, see what percentage of the jury agreed with your judgment.',
      backgroundGradient: [
        const Color(0xFF1A1510),
        const Color(0xFF0A0E17),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final currentPageData = _pageData[_currentPage];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: currentPageData.backgroundGradient,
              ),
            ),
          ),

          // Decorative pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPatternPainter(
                color: currentPageData.accentColor.withAlpha(8),
              ),
            ),
          ),

          // Radial glow from center
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 300 * _pulseAnimation.value,
                    height: 300 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          currentPageData.accentColor.withAlpha(30),
                          currentPageData.accentColor.withAlpha(10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withAlpha(120),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pageData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(context, _pageData[index], index);
                    },
                  ),
                ),

                // Page indicators with progress
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pageData.length,
                      (index) => _buildIndicator(index),
                    ),
                  ),
                ),

                // Action button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: _buildActionButton(currentPageData),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPageData page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with dramatic glow
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _floatAnimation]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          page.accentColor.withAlpha(40),
                          page.accentColor.withAlpha(15),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: page.accentColor.withAlpha(60),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: page.accentColor.withAlpha(25),
                          border: Border.all(
                            color: page.accentColor.withAlpha(80),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          page.icon,
                          size: 48,
                          color: page.accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 56),

          // Subtitle badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: page.accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: page.accentColor.withAlpha(60),
                width: 1,
              ),
            ),
            child: Text(
              page.subtitle,
              style: TextStyle(
                color: page.accentColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 17,
              fontWeight: FontWeight.w400,
              height: 1.6,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = _currentPage == index;
    final accentColor = _pageData[_currentPage].accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? accentColor : Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accentColor.withAlpha(100),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildActionButton(OnboardingPageData currentPageData) {
    final isLastPage = _currentPage == _pageData.length - 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isLastPage) {
            _completeOnboarding();
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                currentPageData.accentColor,
                currentPageData.accentColor.withAlpha(200),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: currentPageData.accentColor.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastPage ? 'Enter the Court' : 'Continue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLastPage
                      ? Icons.gavel_rounded
                      : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for onboarding page content
class OnboardingPageData {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> backgroundGradient;

  OnboardingPageData({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.backgroundGradient,
  });
}

/// Helper to check if onboarding is complete
class OnboardingHelper {
  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', false);
  }
}

/// Custom painter for decorative grid pattern
class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Diagonal accent lines
    final accentPaint = Paint()
      ..color = color.withAlpha((color.alpha * 0.5).round())
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width + size.height; i += spacing * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
