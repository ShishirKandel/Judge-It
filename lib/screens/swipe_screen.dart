import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../providers/swipe_provider.dart';
import '../widgets/story_card.dart';
import '../widgets/result_overlay.dart';

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

  @override
  void initState() {
    super.initState();
    _swiperController = AppinioSwiperController();
    
    // Initialize provider and fetch stories
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
      backgroundColor: const Color(0xFF0D0D14),
      appBar: _buildAppBar(),
      body: Consumer<SwipeProvider>(
        builder: (context, provider, child) {
          // Show result overlay if needed
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
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Judge It',
            style: TextStyle(
              color: Colors.white,
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
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.swipe_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${provider.swipeCount}',
                    style: const TextStyle(
                      color: Colors.white70,
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
    // Loading state
    if (provider.isLoading && provider.stories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.amber,
            ),
            SizedBox(height: 16),
            Text(
              'Loading stories...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (provider.error != null && provider.stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load stories',
              style: TextStyle(
                color: Colors.white.withAlpha(204), // 0.8 opacity
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.reset(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (provider.stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              color: Colors.white.withAlpha(77), // 0.3 opacity
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'No stories to judge',
              style: TextStyle(
                color: Colors.white.withAlpha(153), // 0.6 opacity
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    // No more cards
    if (_currentIndex >= provider.stories.length && !provider.hasMore) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              "You've judged all stories!",
              style: TextStyle(
                color: Colors.white.withAlpha(204), // 0.8 opacity
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Come back later for more',
              style: TextStyle(
                color: Colors.white.withAlpha(128), // 0.5 opacity
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Swiper content
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: AppinioSwiper(
        controller: _swiperController,
        cardCount: provider.stories.length,
        onSwipeEnd: _onSwipeEnd,
        onCardPositionChanged: (position) {
          setState(() {
            _swipeProgress = position.offset.dx / 200;
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
      final isRightSwipe = activity.direction == AxisDirection.right;
      
      setState(() {
        _currentIndex = targetIndex;
        _swipeProgress = 0.0;
      });
      
      context.read<SwipeProvider>().onSwipe(previousIndex, isRightSwipe);
    }
  }
}
