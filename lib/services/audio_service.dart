import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service for managing background music and sound effects.
///
/// Handles audio playback, volume control, and proper lifecycle management.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Audio players - separate player for each sound type
  AudioPlayer? _musicPlayer;
  AudioPlayer? _swipeSfxPlayer;
  AudioPlayer? _voteSfxPlayer;
  AudioPlayer? _badgeSfxPlayer;

  bool _isMusicPlaying = false;
  bool _musicShouldBePlaying = false; // Tracks user intent
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
      // Configure audio context to allow mixing (don't steal audio focus)
      // Using playback category with mixWithOthers for iOS
      // Using AndroidAudioFocus.none for Android to prevent stopping other audio
      final audioContext = AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none, // Don't request audio focus
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      );

      // Create players with mixing context
      _musicPlayer = AudioPlayer()..setAudioContext(audioContext);
      _swipeSfxPlayer = AudioPlayer()..setAudioContext(audioContext);
      _voteSfxPlayer = AudioPlayer()..setAudioContext(audioContext);
      _badgeSfxPlayer = AudioPlayer()..setAudioContext(audioContext);

      // Configure music player for looping
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.3); // Background music at 30% volume

      // Listen for music player state changes
      _musicPlayer!.onPlayerStateChanged.listen((state) {
        _isMusicPlaying = state == PlayerState.playing;
      });

      // Configure SFX players
      await _swipeSfxPlayer!.setReleaseMode(ReleaseMode.release);
      await _swipeSfxPlayer!.setVolume(0.6);

      await _voteSfxPlayer!.setReleaseMode(ReleaseMode.release);
      await _voteSfxPlayer!.setVolume(0.8);

      await _badgeSfxPlayer!.setReleaseMode(ReleaseMode.release);
      await _badgeSfxPlayer!.setVolume(0.9);

      _isInitialized = true;
      debugPrint('AudioService initialized with mixing enabled');
    } catch (e) {
      debugPrint('Failed to initialize AudioService: $e');
      // Initialize with default players as fallback
      _initializeFallbackPlayers();
    }
  }

  /// Fallback initialization without custom audio context
  void _initializeFallbackPlayers() {
    try {
      _musicPlayer = AudioPlayer();
      _swipeSfxPlayer = AudioPlayer();
      _voteSfxPlayer = AudioPlayer();
      _badgeSfxPlayer = AudioPlayer();

      _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      _musicPlayer!.setVolume(0.3);

      _swipeSfxPlayer!.setReleaseMode(ReleaseMode.release);
      _swipeSfxPlayer!.setVolume(0.6);

      _voteSfxPlayer!.setReleaseMode(ReleaseMode.release);
      _voteSfxPlayer!.setVolume(0.8);

      _badgeSfxPlayer!.setReleaseMode(ReleaseMode.release);
      _badgeSfxPlayer!.setVolume(0.9);

      _isInitialized = true;
      debugPrint('AudioService initialized with fallback players');
    } catch (e) {
      debugPrint('Failed fallback initialization: $e');
    }
  }

  /// Start playing background music
  Future<void> playMusic() async {
    if (_musicPlayer == null) return;
    _musicShouldBePlaying = true;

    try {
      await _musicPlayer!.play(AssetSource(_backgroundMusic));
      _isMusicPlaying = true;
      debugPrint('Background music started');
    } catch (e) {
      debugPrint('Failed to play music: $e');
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    if (_musicPlayer == null) return;
    _musicShouldBePlaying = false;

    try {
      await _musicPlayer!.stop();
      _isMusicPlaying = false;
      debugPrint('Background music stopped');
    } catch (e) {
      debugPrint('Failed to stop music: $e');
    }
  }

  /// Pause background music (for app lifecycle)
  Future<void> pauseMusic() async {
    if (_musicPlayer == null) return;

    try {
      await _musicPlayer!.pause();
      debugPrint('Background music paused');
    } catch (e) {
      debugPrint('Failed to pause music: $e');
    }
  }

  /// Resume background music (for app lifecycle)
  Future<void> resumeMusic() async {
    if (_musicPlayer == null || !_musicShouldBePlaying) return;

    try {
      await _musicPlayer!.resume();
      debugPrint('Background music resumed');
    } catch (e) {
      debugPrint('Failed to resume music: $e');
    }
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    if (_musicPlayer == null) return;

    try {
      await _musicPlayer!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Failed to set music volume: $e');
    }
  }

  /// Play swipe sound effect
  Future<void> playSwipeSound() async {
    if (_swipeSfxPlayer == null) return;

    try {
      await _swipeSfxPlayer!.play(AssetSource(_swipeSound));
    } catch (e) {
      debugPrint('Failed to play swipe SFX: $e');
    }
  }

  /// Play NTA vote sound
  Future<void> playNtaSound() async {
    if (_voteSfxPlayer == null) return;

    try {
      await _voteSfxPlayer!.play(AssetSource(_voteNtaSound));
    } catch (e) {
      debugPrint('Failed to play NTA SFX: $e');
    }
  }

  /// Play YTA vote sound
  Future<void> playYtaSound() async {
    if (_voteSfxPlayer == null) return;

    try {
      await _voteSfxPlayer!.play(AssetSource(_voteYtaSound));
    } catch (e) {
      debugPrint('Failed to play YTA SFX: $e');
    }
  }

  /// Play badge unlock celebration sound
  Future<void> playBadgeUnlockSound() async {
    if (_badgeSfxPlayer == null) return;

    try {
      await _badgeSfxPlayer!.play(AssetSource(_badgeUnlockSound));
    } catch (e) {
      debugPrint('Failed to play badge SFX: $e');
    }
  }

  /// Dispose audio players
  Future<void> dispose() async {
    await _musicPlayer?.dispose();
    await _swipeSfxPlayer?.dispose();
    await _voteSfxPlayer?.dispose();
    await _badgeSfxPlayer?.dispose();
    _musicPlayer = null;
    _swipeSfxPlayer = null;
    _voteSfxPlayer = null;
    _badgeSfxPlayer = null;
    _isInitialized = false;
    _isMusicPlaying = false;
    _musicShouldBePlaying = false;
  }

  /// Check if music is currently playing
  bool get isMusicPlaying => _isMusicPlaying;

  /// Check if music should be playing (user preference)
  bool get musicShouldBePlaying => _musicShouldBePlaying;
}
