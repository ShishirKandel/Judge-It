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
import 'stats_screen.dart';

/// Main swipe screen for judging stories.
///
/// Uses AppinioSwiper for card swiping with infinite scroll.
class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  late AppinioSwiperController _swiperController;
  int _currentIndex = 0;
  double _swipeProgress = 0.0;

  /// Divisor for converting swipe offset to progress (-1.0 to 1.0)
  static const double _swipeProgressDivisor = 200.0;

  @override
  void initState() {
    super.initState();
    _swiperController = AppinioSwiperController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SwipeProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, _swipeProgress),
      body: Stack(
        children: [
          // Swiper - only rebuilds when stories/loading/error changes
          Selector<SwipeProvider, ({List<Story> stories, bool isLoading, String? error, bool hasMore})>(
            selector: (_, provider) => (
              stories: provider.stories,
              isLoading: provider.isLoading,
              error: provider.error,
              hasMore: provider.hasMore,
            ),
            builder: (context, data, child) {
              final provider = context.read<SwipeProvider>();
              return _buildSwiperContentFromData(
                context,
                data.stories,
                data.isLoading,
                data.error,
                data.hasMore,
                provider,
              );
            },
          ),
          
          // Result overlay - separate Consumer, doesn't rebuild swiper
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
  
  Widget _buildSwiperContentFromData(
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

    return _buildSwiperFromStories(stories);
  }
  
  Widget _buildSwiperFromStories(List<Story> stories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, double swipeProgress) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate app bar background color based on swipe direction
    Color? appBarColor;
    if (swipeProgress > 0.1) {
      // Swiping right - NTA (green)
      final intensity = (swipeProgress.clamp(0.0, 1.0) * 0.3);
      appBarColor = Color.lerp(
        colorScheme.surface,
        AppTheme.nta,
        intensity,
      );
    } else if (swipeProgress < -0.1) {
      // Swiping left - YTA (red)
      final intensity = ((-swipeProgress).clamp(0.0, 1.0) * 0.3);
      appBarColor = Color.lerp(
        colorScheme.surface,
        AppTheme.yta,
        intensity,
      );
    }

    return AppBar(
      centerTitle: true,
      backgroundColor: appBarColor,
      leading: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Material(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => themeProvider.toggleTheme(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      themeProvider.themeIcon,
                      key: ValueKey(themeProvider.isDarkMode),
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.gavel_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Judge It',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        // Streak indicator
        Consumer<StatsProvider>(
          builder: (context, statsProvider, _) {
            final streak = statsProvider.currentStreak;
            if (streak < 2) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Music toggle button
        Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                onPressed: () {
                  settings.toggleMusic();
                  if (settings.musicEnabled) {
                    AudioService().playMusic();
                  } else {
                    AudioService().stopMusic();
                  }
                },
                icon: Icon(
                  settings.musicEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: settings.musicEnabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                tooltip: settings.musicEnabled ? 'Music On' : 'Music Off',
              ),
            );
          },
        ),
        // Stats button
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Material(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading stories...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: colorScheme.onErrorContainer,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load stories',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => provider.reset(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No stories to judge',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.nta.withAlpha(30),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.nta.withAlpha(40),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.nta,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "You've judged all stories!",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Come back later for more',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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
