// utils/highscore_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreManager {
  static const String _key = 'highScore';

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = await getHighScore();
    if (score > currentHighScore) {
      await prefs.setInt(_key, score);
    }
  }
}