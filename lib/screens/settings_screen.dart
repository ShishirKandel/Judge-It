import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../services/audio_service.dart';

/// Settings screen for app preferences.
///
/// Design: Clean, elegant settings with grouped sections.
/// Allows users to configure audio settings, avatar selection, and appearance.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
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
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Settings',
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

          // Settings content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    // Audio Section
                    _buildSectionHeader(
                      context,
                      'Audio',
                      Icons.headphones_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildSettingsCard(
                      context,
                      isDark,
                      children: [
                        _buildSwitchTile(
                          context: context,
                          title: 'Background Music',
                          subtitle: 'Play ambient music while judging',
                          icon: Icons.music_note_rounded,
                          value: settings.musicEnabled,
                          onChanged: (value) {
                            settings.setMusicEnabled(value);
                            if (value) {
                              AudioService().playMusic();
                            } else {
                              AudioService().stopMusic();
                            }
                          },
                        ),
                        _buildDivider(context),
                        _buildSwitchTile(
                          context: context,
                          title: 'Sound Effects',
                          subtitle: 'Play sounds on swipe and vote',
                          icon: Icons.volume_up_rounded,
                          value: settings.soundEffectsEnabled,
                          onChanged: (value) => settings.setSoundEffectsEnabled(value),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Avatar Section
                    _buildSectionHeader(
                      context,
                      'Avatar',
                      Icons.face_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildSettingsCard(
                      context,
                      isDark,
                      children: [
                        _buildAvatarOption(
                          context: context,
                          title: 'Classic',
                          subtitle: 'Emoji-based reactions',
                          icon: '🎭',
                          isSelected: settings.avatarType == AvatarType.classic,
                          onTap: () => settings.setAvatarType(AvatarType.classic),
                        ),
                        _buildDivider(context),
                        _buildAvatarOption(
                          context: context,
                          title: 'Boy Avatar',
                          subtitle: 'Animated character',
                          icon: '👦',
                          isSelected: settings.avatarType == AvatarType.boy,
                          onTap: () => settings.setAvatarType(AvatarType.boy),
                        ),
                        _buildDivider(context),
                        _buildAvatarOption(
                          context: context,
                          title: 'Girl Avatar',
                          subtitle: 'Animated character',
                          icon: '👧',
                          isSelected: settings.avatarType == AvatarType.girl,
                          onTap: () => settings.setAvatarType(AvatarType.girl),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Appearance Section
                    _buildSectionHeader(
                      context,
                      'Appearance',
                      Icons.palette_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildSettingsCard(
                      context,
                      isDark,
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return _buildSwitchTile(
                              context: context,
                              title: 'Dark Mode',
                              subtitle: 'Use dark theme for the app',
                              icon: Icons.dark_mode_rounded,
                              value: themeProvider.isDarkMode,
                              onChanged: (_) => themeProvider.toggleTheme(),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // App Info
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.gavel_rounded,
                              color: colorScheme.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Judge It',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]),
                );
              },
            ),
          ),
        ],
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
          child: Icon(icon, color: colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    bool isDark, {
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
          color: colorScheme.outlineVariant.withAlpha(60),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(30) : Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: colorScheme.outlineVariant.withAlpha(40),
        height: 1,
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: value
              ? colorScheme.primary.withAlpha(20)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: value
              ? Border.all(color: colorScheme.primary.withAlpha(40), width: 1)
              : null,
        ),
        child: Icon(
          icon,
          color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAvatarOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withAlpha(20)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : Border.all(color: colorScheme.outlineVariant.withAlpha(60), width: 1),
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 26)),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: isSelected
              ? null
              : Border.all(color: colorScheme.outlineVariant, width: 2),
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
