import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';

/// Service for persisting user stats to SharedPreferences.
class StatsService {
  static const String _statsKey = 'user_stats';

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Load user stats from storage
  Future<UserStats> loadStats() async {
    if (_prefs == null) await initialize();

    final data = _prefs!.getString(_statsKey);
    if (data == null) return const UserStats();

    try {
      return UserStats.deserialize(data);
    } catch (e) {
      // If parsing fails, return default stats
      return const UserStats();
    }
  }

  /// Save user stats to storage
  Future<void> saveStats(UserStats stats) async {
    if (_prefs == null) await initialize();

    await _prefs!.setString(_statsKey, stats.serialize());
  }

  /// Clear all stats (for testing/reset)
  Future<void> clearStats() async {
    if (_prefs == null) await initialize();

    await _prefs!.remove(_statsKey);
  }
}
