import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil {
  static const _lastOpenedKey = 'last_opened';
  static const _statusKey = 'filter_status';
  static const _genreKey = 'filter_genres';
  static const _ratingKey = 'filter_rating';
  static const _minScoreKey = 'filter_min_score';

  static Future<void> saveLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_lastOpenedKey, now);
  }

  static Future<String?> getLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastOpenedKey);
  }

  static Future<void> saveFilterPreferences({
    required String status,
    required Set<String> genres,
    required String rating,
    required double minScore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey, status);
    await prefs.setStringList(_genreKey, genres.toList());
    await prefs.setString(_ratingKey, rating);
    await prefs.setDouble(_minScoreKey, minScore);
  }

  static Future<Map<String, dynamic>> getFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'status': prefs.getString(_statusKey) ?? '',
      'genres': prefs.getStringList(_genreKey) ?? <String>[],
      'rating': prefs.getString(_ratingKey) ?? '',
      'minScore': prefs.getDouble(_minScoreKey) ?? 0.0,
    };
  }
}
