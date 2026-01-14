import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service for managing background music and sound effects.
/// 
/// Handles audio playback, volume control, and proper lifecycle management.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();
  
  // Audio players
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _isMusicPlaying = false;
  bool _isInitialized = false;
  
  // Asset paths
  static const String _backgroundMusic = 'audio/background_music.mp3';
  static const String _swipeSound = 'audio/swipe_whoosh.mp3';
  static const String _voteNtaSound = 'audio/vote_nta.mp3';
  static const String _voteYtaSound = 'audio/vote_yta.mp3';
  static const String _badgeUnlockSound = 'audio/badge_unlock.mp3';
  
  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Configure music player for looping
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.3); // Background music at 30% volume
      
      // Configure SFX player
      await _sfxPlayer.setReleaseMode(ReleaseMode.release);
      await _sfxPlayer.setVolume(0.7); // Sound effects at 70% volume
      
      _isInitialized = true;
      debugPrint('AudioService initialized');
    } catch (e) {
      debugPrint('Failed to initialize AudioService: $e');
    }
  }
  
  /// Start playing background music
  Future<void> playMusic() async {
    if (_isMusicPlaying) return;
    
    try {
      await _musicPlayer.play(AssetSource(_backgroundMusic));
      _isMusicPlaying = true;
      debugPrint('Background music started');
    } catch (e) {
      debugPrint('Failed to play music: $e');
    }
  }
  
  /// Stop background music
  Future<void> stopMusic() async {
    if (!_isMusicPlaying) return;
    
    try {
      await _musicPlayer.stop();
      _isMusicPlaying = false;
      debugPrint('Background music stopped');
    } catch (e) {
      debugPrint('Failed to stop music: $e');
    }
  }
  
  /// Pause background music (for app lifecycle)
  Future<void> pauseMusic() async {
    if (!_isMusicPlaying) return;
    
    try {
      await _musicPlayer.pause();
      debugPrint('Background music paused');
    } catch (e) {
      debugPrint('Failed to pause music: $e');
    }
  }
  
  /// Resume background music (for app lifecycle)
  Future<void> resumeMusic() async {
    if (!_isMusicPlaying) return;
    
    try {
      await _musicPlayer.resume();
      debugPrint('Background music resumed');
    } catch (e) {
      debugPrint('Failed to resume music: $e');
    }
  }
  
  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    try {
      await _musicPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Failed to set music volume: $e');
    }
  }
  
  /// Play swipe sound effect
  Future<void> playSwipeSound() async {
    await _playSfx(_swipeSound);
  }
  
  /// Play NTA vote sound
  Future<void> playNtaSound() async {
    await _playSfx(_voteNtaSound);
  }
  
  /// Play YTA vote sound
  Future<void> playYtaSound() async {
    await _playSfx(_voteYtaSound);
  }
  
  /// Play badge unlock celebration sound
  Future<void> playBadgeUnlockSound() async {
    await _playSfx(_badgeUnlockSound);
  }
  
  /// Internal method to play sound effects
  Future<void> _playSfx(String assetPath) async {
    try {
      await _sfxPlayer.stop(); // Stop any currently playing SFX
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Failed to play SFX $assetPath: $e');
    }
  }
  
  /// Dispose audio players
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
    _isInitialized = false;
    _isMusicPlaying = false;
  }
  
  /// Check if music is currently playing
  bool get isMusicPlaying => _isMusicPlaying;
}
