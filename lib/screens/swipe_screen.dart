import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../models/story.dart';
import '../providers/swipe_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import '../widgets/story_card.dart';
import '../widgets/result_overlay.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import 'stats_screen.dart';

/// Main swipe screen for judging stories.
///
/// Design: Dramatic courtroom experience with immersive card swiping.
/// Uses AppinioSwiper for card swiping with infinite scroll.
class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin {
  late AppinioSwiperController _swiperController;
  int _currentIndex = 0;
  double _swipeProgress = 0.0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  /// Divisor for converting swipe offset to progress (-1.0 to 1.0)
  static const double _swipeProgressDivisor = 200.0;

  @override
  void initState() {
    super.initState();
    _swiperController = AppinioSwiperController();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SwipeProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient background glow based on swipe direction
          if (_swipeProgress.abs() > 0.1)
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(_swipeProgress > 0 ? 0.8 : -0.8, -0.3),
                    radius: 1.5,
                    colors: [
                      (_swipeProgress > 0 ? AppTheme.nta : AppTheme.yta)
                          .withAlpha(((_swipeProgress.abs() * 40).round())),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(context),

                // Swiper content
                Expanded(
                  child:
                      Selector<
                        SwipeProvider,
                        ({
                          List<Story> stories,
                          bool isLoading,
                          String? error,
                          bool hasMore,
                        })
                      >(
                        selector: (_, provider) => (
                          stories: provider.stories,
                          isLoading: provider.isLoading,
                          error: provider.error,
                          hasMore: provider.hasMore,
                        ),
                        builder: (context, data, child) {
                          final provider = context.read<SwipeProvider>();
                          return _buildSwiperContent(
                            context,
                            data.stories,
                            data.isLoading,
                            data.error,
                            data.hasMore,
                            provider,
                          );
                        },
                      ),
                ),
              ],
            ),
          ),

          // Result overlay
          Consumer<SwipeProvider>(
            builder: (context, provider, child) {
              if (provider.showingResult && provider.lastVoteType != null) {
                return ResultOverlay(
                  voteType: provider.lastVoteType!,
                  agreementPercentage: provider.agreementPercentage,
                  agreedWithMajority: provider.agreedWithMajority,
                  storyId: provider.lastVotedStory?.id,
                  onDismiss: () => provider.dismissResult(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return _buildIconButton(
                icon: themeProvider.themeIcon,
                onTap: () => themeProvider.toggleTheme(),
                colorScheme: colorScheme,
                isDark: isDark,
              );
            },
          ),

          const Spacer(),

          // Logo and title
          _buildLogoTitle(theme, colorScheme),

          const Spacer(),

          // Streak indicator
          Consumer<StatsProvider>(
            builder: (context, statsProvider, _) {
              final streak = statsProvider.currentStreak;
              if (streak >= 2) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildStreakBadge(streak, theme),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Music toggle
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildIconButton(
                  icon: settings.musicEnabled
                      ? Icons.music_note_rounded
                      : Icons.music_off_rounded,
                  onTap: () {
                    settings.toggleMusic();
                    if (settings.musicEnabled) {
                      AudioService().playMusic();
                    } else {
                      AudioService().stopMusic();
                    }
                  },
                  colorScheme: colorScheme,
                  isDark: isDark,
                  isActive: settings.musicEnabled,
                ),
              );
            },
          ),

          // Stats button
          _buildIconButton(
            icon: Icons.bar_chart_rounded,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const StatsScreen()));
            },
            colorScheme: colorScheme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
    bool isActive = true,
  }) {
    return Material(
      color: isDark
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isActive
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoTitle(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gavel icon with glow
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withAlpha(40),
                    colorScheme.primary.withAlpha(20),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.primary.withAlpha(60),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(
                      (_glowAnimation.value * 80).round(),
                    ),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.gavel_rounded,
                color: colorScheme.primary,
                size: 22,
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Text(
          'Judge It',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakBadge(int streak, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.streakFire.withAlpha(30),
            AppColors.streakFireGlow.withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.streakFire.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.streakFire,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiperContent(
    BuildContext context,
    List<Story> stories,
    bool isLoading,
    String? error,
    bool hasMore,
    SwipeProvider provider,
  ) {
    if (isLoading && stories.isEmpty) {
      return _buildLoadingState(context);
    }

    if (error != null && stories.isEmpty) {
      return _buildErrorState(context, provider);
    }

    if (stories.isEmpty) {
      return _buildEmptyState(context);
    }

    if (_currentIndex >= stories.length && !hasMore) {
      return _buildCompletedState(context);
    }

    return _buildSwiper(stories);
  }

  Widget _buildSwiper(List<Story> stories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: AppinioSwiper(
        key: const ValueKey('main_swiper'),
        controller: _swiperController,
        cardCount: stories.length,
        onSwipeEnd: _onSwipeEnd,
        onCardPositionChanged: (position) {
          setState(() {
            _swipeProgress = position.offset.dx / _swipeProgressDivisor;
          });
        },
        cardBuilder: (context, index) {
          if (index >= stories.length) {
            return const SizedBox.shrink();
          }

          return StoryCard(
            story: stories[index],
            swipeProgress: index == _currentIndex ? _swipeProgress : 0.0,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
                Icon(Icons.gavel_rounded, color: colorScheme.primary, size: 24),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Loading cases...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SwipeProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withAlpha(40),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.error.withAlpha(60),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: colorScheme.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Failed to load cases',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.error ?? 'An unexpected error occurred',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () => provider.reset(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant, width: 2),
              ),
              child: Icon(
                Icons.inbox_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 56,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No cases to judge',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The courtroom is empty.\nCheck back later for new cases.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.nta.withAlpha(30),
                    AppTheme.nta.withAlpha(10),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.nta.withAlpha(40),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.nta.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: Icon(Icons.check_rounded, color: AppTheme.nta, size: 48),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'All cases judged!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve reviewed all available cases.\nCome back later for more.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onSwipeEnd(
    int previousIndex,
    int targetIndex,
    SwiperActivity activity,
  ) {
    if (activity is Swipe) {
      setState(() {
        _currentIndex = targetIndex;
        _swipeProgress = 0.0;
      });

      final direction = activity.direction;

      // Play swipe sound if enabled
      final settings = context.read<SettingsProvider>();
      if (settings.soundEffectsEnabled) {
        AudioService().playSwipeSound();
      }

      if (direction == AxisDirection.up) {
        // Swipe up = Skip
        context.read<SwipeProvider>().onSkip(previousIndex);
      } else if (direction == AxisDirection.right) {
        // Swipe right = NTA
        _handleVote(previousIndex, true);
      } else if (direction == AxisDirection.left) {
        // Swipe left = YTA
        _handleVote(previousIndex, false);
      }
      // Swipe down is ignored (could be accidental)
    }
  }

  /// Handle a vote and record stats
  Future<void> _handleVote(int storyIndex, bool isNta) async {
    final swipeProvider = context.read<SwipeProvider>();
    final statsProvider = context.read<StatsProvider>();
    final settings = context.read<SettingsProvider>();

    // Play vote sound effect if enabled
    if (settings.soundEffectsEnabled) {
      if (isNta) {
        AudioService().playNtaSound();
      } else {
        AudioService().playYtaSound();
      }
    }

    // First trigger the swipe (shows result overlay)
    await swipeProvider.onSwipe(storyIndex, isNta);

    // Then record stats and get any new badges
    final newBadges = await statsProvider.recordJudgment(
      isNta: isNta,
      agreedWithMajority: swipeProvider.agreedWithMajority,
    );

    // Update swipe provider with new badges for display
    if (newBadges.isNotEmpty) {
      swipeProvider.setNewlyUnlockedBadges(newBadges);
    }
  }
}
