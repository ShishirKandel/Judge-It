import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_stats.dart';
import '../providers/stats_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_card.dart';
import 'settings_screen.dart';

/// Screen displaying user statistics and earned badges.
///
/// Design: Judicial record card aesthetic with dramatic data visualization.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, child) {
          final stats = statsProvider.stats;

          return CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.analytics_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Your Record',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.only(bottom: 16),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Main stats hero cards
                    _buildHeroStats(context, stats),
                    const SizedBox(height: 28),

                    // Voting tendency section
                    _buildVotingTendency(context, stats),
                    const SizedBox(height: 28),

                    // Badges section
                    _buildSectionHeader(
                      context,
                      'Badges',
                      Icons.military_tech_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildBadgesGrid(context, statsProvider),
                    const SizedBox(height: 28),

                    // Global community stats
                    _buildSectionHeader(
                      context,
                      'Community',
                      Icons.public_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildGlobalStats(context),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStats(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _HeroStatCard(
            icon: Icons.gavel_rounded,
            label: 'Total Judgments',
            value: '${stats.totalJudgments}',
            color: colorScheme.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _HeroStatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Current Streak',
            value: '${stats.currentStreak}',
            color: AppColors.streakFire,
            isDark: isDark,
            showGlow: stats.currentStreak >= 5,
          ),
        ),
      ],
    );
  }

  Widget _buildVotingTendency(BuildContext context, UserStats stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final total = stats.ntaVotes + stats.ytaVotes;
    final ntaPercent = total > 0 ? stats.ntaVotes / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHigh,
                  colorScheme.surfaceContainer,
                ]
              : [
                  Colors.white,
                  colorScheme.surfaceContainerLow,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(60),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(40) : Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.balance_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Voting Pattern',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${(stats.accuracyPercentage * 100).toStringAsFixed(0)}% accuracy',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  Expanded(
                    flex: (ntaPercent * 100).round().clamp(1, 99),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.ntaGradient,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: ((1 - ntaPercent) * 100).round().clamp(1, 99),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.ytaGradient,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.nta,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'NTA: ${stats.ntaVotes}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'YTA: ${stats.ytaVotes}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.yta,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Additional stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MiniStat(
                  label: 'Best Streak',
                  value: '${stats.bestStreak}',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.gold,
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: colorScheme.outlineVariant.withAlpha(60),
                ),
                _MiniStat(
                  label: 'Agreements',
                  value: '${stats.agreementsWithMajority}',
                  icon: Icons.handshake_rounded,
                  color: AppTheme.nta,
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: colorScheme.outlineVariant.withAlpha(60),
                ),
                _MiniStat(
                  label: 'Contrarian',
                  value: '${stats.disagreementsWithMajority}',
                  icon: Icons.psychology_alt_rounded,
                  color: AppTheme.skip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context, StatsProvider statsProvider) {
    final badges = AppBadge.allBadges;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85, // More height for content
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isEarned = statsProvider.hasBadge(badge.type);
        final progress = statsProvider.getBadgeProgress(badge.type);

        return BadgeCard(
          badge: badge,
          isEarned: isEarned,
          progress: progress,
        );
      },
    );
  }

  Widget _buildGlobalStats(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<GlobalAppStats>(
      stream: _firestoreService.watchGlobalStats(),
      builder: (context, snapshot) {
        final globalStats = snapshot.data ?? const GlobalAppStats();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withAlpha(isDark ? 30 : 20),
                colorScheme.primaryContainer.withAlpha(isDark ? 40 : 30),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.primary.withAlpha(40),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.public_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Global Stats',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (snapshot.connectionState == ConnectionState.active)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.nta.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.nta.withAlpha(40),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.nta,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Live',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.nta,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _GlobalStatItem(
                      icon: Icons.gavel_rounded,
                      label: 'Total Judgments',
                      value: _formatNumber(globalStats.totalJudgments),
                    ),
                  ),
                  Expanded(
                    child: _GlobalStatItem(
                      icon: Icons.today_rounded,
                      label: 'Today',
                      value: _formatNumber(globalStats.storiesJudgedToday),
                    ),
                  ),
                  Expanded(
                    child: _GlobalStatItem(
                      icon: Icons.people_rounded,
                      label: 'Active Now',
                      value: _formatNumber(globalStats.activeUsersToday),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _HeroStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final bool showGlow;

  const _HeroStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surfaceContainerHigh,
                  colorScheme.surfaceContainer,
                ]
              : [
                  Colors.white,
                  colorScheme.surfaceContainerLow,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: showGlow ? color.withAlpha(80) : colorScheme.outlineVariant.withAlpha(60),
          width: showGlow ? 2 : 1,
        ),
        boxShadow: [
          if (showGlow)
            BoxShadow(
              color: color.withAlpha(40),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(40) : Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withAlpha(40),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _GlobalStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GlobalStatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, size: 26, color: colorScheme.primary),
        const SizedBox(height: 10),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
