import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../services/audio_service.dart';

/// Settings screen for app preferences.
/// 
/// Allows users to configure audio settings and avatar selection.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Audio Section
              _buildSectionHeader(theme, colorScheme, 'Audio', Icons.music_note_rounded),
              const SizedBox(height: 12),
              _buildSettingsCard(
                colorScheme,
                children: [
                  _buildSwitchTile(
                    title: 'Background Music',
                    subtitle: 'Play ambient music while judging',
                    icon: Icons.headphones_rounded,
                    value: settings.musicEnabled,
                    onChanged: (value) {
                      settings.setMusicEnabled(value);
                      if (value) {
                        AudioService().playMusic();
                      } else {
                        AudioService().stopMusic();
                      }
                    },
                    colorScheme: colorScheme,
                  ),
                  Divider(color: colorScheme.outlineVariant.withAlpha(50)),
                  _buildSwitchTile(
                    title: 'Sound Effects',
                    subtitle: 'Play sounds on swipe and vote',
                    icon: Icons.volume_up_rounded,
                    value: settings.soundEffectsEnabled,
                    onChanged: (value) => settings.setSoundEffectsEnabled(value),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Avatar Section
              _buildSectionHeader(theme, colorScheme, 'Avatar', Icons.face_rounded),
              const SizedBox(height: 12),
              _buildSettingsCard(
                colorScheme,
                children: [
                  _buildAvatarOption(
                    title: 'Classic',
                    subtitle: 'Emoji-based reactions',
                    icon: '😊',
                    isSelected: settings.avatarType == AvatarType.classic,
                    onTap: () => settings.setAvatarType(AvatarType.classic),
                    colorScheme: colorScheme,
                  ),
                  Divider(color: colorScheme.outlineVariant.withAlpha(50)),
                  _buildAvatarOption(
                    title: 'Boy Avatar',
                    subtitle: 'Animated character',
                    icon: '👦',
                    isSelected: settings.avatarType == AvatarType.boy,
                    onTap: () => settings.setAvatarType(AvatarType.boy),
                    colorScheme: colorScheme,
                  ),
                  Divider(color: colorScheme.outlineVariant.withAlpha(50)),
                  _buildAvatarOption(
                    title: 'Girl Avatar',
                    subtitle: 'Animated character',
                    icon: '👧',
                    isSelected: settings.avatarType == AvatarType.girl,
                    onTap: () => settings.setAvatarType(AvatarType.girl),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Theme Section
              _buildSectionHeader(theme, colorScheme, 'Appearance', Icons.palette_rounded),
              const SizedBox(height: 12),
              _buildSettingsCard(
                colorScheme,
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return _buildSwitchTile(
                        title: 'Dark Mode',
                        subtitle: 'Use dark theme',
                        icon: Icons.dark_mode_rounded,
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // App Info
              Center(
                child: Text(
                  'Judge It v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, ColorScheme colorScheme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(ColorScheme colorScheme, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAvatarOption({
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primary.withAlpha(30)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: isSelected 
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 24)),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
          : Icon(Icons.circle_outlined, color: colorScheme.outlineVariant),
    );
  }
}
