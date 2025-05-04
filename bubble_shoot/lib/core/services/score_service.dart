import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _highScoresKey = 'high_scores';
  static const int _maxScores = 10;

  Future<List<int>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList(_highScoresKey) ?? [];
    return scores.map(int.parse).toList()..sort((a, b) => b.compareTo(a));
  }

  Future<void> saveScore(int score) async {
    final scores = await getHighScores();
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a));
    
    if (scores.length > _maxScores) {
      scores.removeRange(_maxScores, scores.length);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _highScoresKey,
      scores.map((score) => score.toString()).toList(),
    );
  }

  Future<bool> isHighScore(int score) async {
    final scores = await getHighScores();
    return scores.length < _maxScores || score > scores.last;
  }
} 