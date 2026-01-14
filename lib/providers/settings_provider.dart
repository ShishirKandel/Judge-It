import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available avatar types
enum AvatarType {
  classic,  // Emoji-based (current)
  boy,      // Animated boy character
  girl,     // Animated girl character
}

/// Settings provider for app preferences.
/// 
/// Manages user settings for audio, avatars, and other preferences.
class SettingsProvider extends ChangeNotifier {
  static const String _musicEnabledKey = 'music_enabled';
  static const String _soundEffectsEnabledKey = 'sound_effects_enabled';
  static const String _avatarTypeKey = 'avatar_type';
  
  bool _musicEnabled = true;  // Default ON for engagement
  bool _soundEffectsEnabled = true;  // Default ON for feedback
  AvatarType _avatarType = AvatarType.classic;
  bool _isLoaded = false;
  
  // Getters
  bool get musicEnabled => _musicEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  AvatarType get avatarType => _avatarType;
  bool get isLoaded => _isLoaded;
  
  /// Initialize settings from SharedPreferences
  Future<void> loadSettings() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _musicEnabled = prefs.getBool(_musicEnabledKey) ?? true;
      _soundEffectsEnabled = prefs.getBool(_soundEffectsEnabledKey) ?? true;
      
      final avatarIndex = prefs.getInt(_avatarTypeKey) ?? 0;
      _avatarType = AvatarType.values[avatarIndex.clamp(0, AvatarType.values.length - 1)];
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }
  
  /// Toggle background music
  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    notifyListeners();
    await _savePreference(_musicEnabledKey, _musicEnabled);
  }
  
  /// Set music enabled state
  Future<void> setMusicEnabled(bool enabled) async {
    if (_musicEnabled == enabled) return;
    _musicEnabled = enabled;
    notifyListeners();
    await _savePreference(_musicEnabledKey, _musicEnabled);
  }
  
  /// Toggle sound effects
  Future<void> toggleSoundEffects() async {
    _soundEffectsEnabled = !_soundEffectsEnabled;
    notifyListeners();
    await _savePreference(_soundEffectsEnabledKey, _soundEffectsEnabled);
  }
  
  /// Set sound effects enabled state
  Future<void> setSoundEffectsEnabled(bool enabled) async {
    if (_soundEffectsEnabled == enabled) return;
    _soundEffectsEnabled = enabled;
    notifyListeners();
    await _savePreference(_soundEffectsEnabledKey, _soundEffectsEnabled);
  }
  
  /// Set avatar type
  Future<void> setAvatarType(AvatarType type) async {
    if (_avatarType == type) return;
    _avatarType = type;
    notifyListeners();
    await _savePreference(_avatarTypeKey, type.index);
  }
  
  /// Save a boolean preference
  Future<void> _savePreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      }
    } catch (e) {
      debugPrint('Failed to save preference $key: $e');
    }
  }
}
