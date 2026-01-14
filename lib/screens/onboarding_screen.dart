import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Onboarding screen that explains the swipe gestures.
///
/// Shows only on first app launch, then remembers completion.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page configurations - colors are semantic, actual rendering adapts to theme
  static final List<OnboardingPageData> _pageData = [
    OnboardingPageData(
      icon: Icons.gavel_rounded,
      accentColor: const Color(0xFFF59E0B), // Amber
      title: 'Welcome to Judge It!',
      description: 'Read real stories and decide:\nAre they the A**hole or not?',
    ),
    OnboardingPageData(
      icon: Icons.arrow_forward_rounded,
      accentColor: AppTheme.nta,
      title: 'Swipe Right = NTA',
      description:
          'Not the A**hole\n\nSwipe right if you think they did nothing wrong.',
    ),
    OnboardingPageData(
      icon: Icons.arrow_back_rounded,
      accentColor: AppTheme.yta,
      title: 'Swipe Left = YTA',
      description:
          "You're the A**hole\n\nSwipe left if you think they were wrong.",
    ),
    OnboardingPageData(
      icon: Icons.arrow_upward_rounded,
      accentColor: const Color(0xFF3B82F6), // Blue
      title: 'Swipe Up = Skip',
      description: "Not interested?\n\nSwipe up to skip to the next story.",
    ),
    OnboardingPageData(
      icon: Icons.percent_rounded,
      accentColor: const Color(0xFF8B5CF6), // Purple
      title: 'See the Results!',
      description: 'After voting, see what percentage of people agreed with you.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final currentPageData = _pageData[_currentPage];

    return Scaffold(
      backgroundColor: _getBackgroundColor(
        currentPageData.accentColor,
        colorScheme,
        isDark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.white.withAlpha(150)
                        : colorScheme.onSurface.withAlpha(150),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16),
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
                  return _buildPage(context, _pageData[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pageData.length,
                  (index) => _buildDot(context, index),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    if (_currentPage < _pageData.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: currentPageData.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: currentPageData.accentColor.withAlpha(100),
                  ),
                  child: Text(
                    _currentPage < _pageData.length - 1 ? 'Next' : 'Get Started!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(
    Color accentColor,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (isDark) {
      // Create a subtle tinted dark background
      return Color.lerp(
        colorScheme.surface,
        accentColor,
        0.08,
      )!;
    } else {
      // Create a subtle tinted light background
      return Color.lerp(
        colorScheme.surface,
        accentColor,
        0.05,
      )!;
    }
  }

  Widget _buildPage(BuildContext context, OnboardingPageData page) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow effect
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.accentColor.withAlpha(isDark ? 40 : 30),
              boxShadow: [
                BoxShadow(
                  color: page.accentColor.withAlpha(isDark ? 60 : 40),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.accentColor,
            ),
          ),
          const SizedBox(height: 56),

          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withAlpha(isDark ? 200 : 180),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 28 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive
            ? _pageData[_currentPage].accentColor
            : (isDark
                ? Colors.white.withAlpha(60)
                : colorScheme.onSurface.withAlpha(60)),
        borderRadius: BorderRadius.circular(5),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: _pageData[_currentPage].accentColor.withAlpha(80),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

/// Data class for onboarding page content
class OnboardingPageData {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;

  OnboardingPageData({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
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
