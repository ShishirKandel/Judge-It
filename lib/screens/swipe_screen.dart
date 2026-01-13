import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../providers/swipe_provider.dart';
import '../widgets/story_card.dart';
import '../widgets/result_overlay.dart';
import '../theme/app_colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<SwipeProvider>(
        builder: (context, provider, child) {
          if (provider.showingResult) {
            return Stack(
              children: [
                _buildSwiperContent(provider),
                ResultOverlay(
                  voteType: provider.lastVoteType!,
                  agreementPercentage: provider.agreementPercentage,
                  onDismiss: () => provider.dismissResult(),
                ),
              ],
            );
          }

          return _buildSwiperContent(provider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Judge It',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<SwipeProvider>(
          builder: (context, provider, _) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.swipe_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${provider.swipeCount}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSwiperContent(SwipeProvider provider) {
    if (provider.isLoading && provider.stories.isEmpty) {
      return _buildLoadingState();
    }

    if (provider.error != null && provider.stories.isEmpty) {
      return _buildErrorState(provider);
    }

    if (provider.stories.isEmpty) {
      return _buildEmptyState();
    }

    if (_currentIndex >= provider.stories.length && !provider.hasMore) {
      return _buildCompletedState();
    }

    return _buildSwiper(provider);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading stories...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SwipeProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.yta, size: 64),
          const SizedBox(height: 16),
          Text(
            'Failed to load stories',
            style: TextStyle(color: AppColors.white80, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.reset(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, color: AppColors.white30, size: 80),
          const SizedBox(height: 16),
          Text(
            'No stories to judge',
            style: TextStyle(color: AppColors.white60, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.nta, size: 80),
          const SizedBox(height: 16),
          Text(
            "You've judged all stories!",
            style: TextStyle(
              color: AppColors.white80,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Come back later for more',
            style: TextStyle(color: AppColors.white50, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiper(SwipeProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: AppinioSwiper(
        controller: _swiperController,
        cardCount: provider.stories.length,
        onSwipeEnd: _onSwipeEnd,
        onCardPositionChanged: (position) {
          setState(() {
            _swipeProgress = position.offset.dx / _swipeProgressDivisor;
          });
        },
        cardBuilder: (context, index) {
          if (index >= provider.stories.length) {
            return const SizedBox.shrink();
          }

          return StoryCard(
            story: provider.stories[index],
            swipeProgress: index == _currentIndex ? _swipeProgress : 0.0,
          );
        },
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
      
      if (direction == AxisDirection.up) {
        // Swipe up = Skip
        context.read<SwipeProvider>().onSkip(previousIndex);
      } else if (direction == AxisDirection.right) {
        // Swipe right = NTA
        context.read<SwipeProvider>().onSwipe(previousIndex, true);
      } else if (direction == AxisDirection.left) {
        // Swipe left = YTA
        context.read<SwipeProvider>().onSwipe(previousIndex, false);
      }
      // Swipe down is ignored (could be accidental)
    }
  }
}
