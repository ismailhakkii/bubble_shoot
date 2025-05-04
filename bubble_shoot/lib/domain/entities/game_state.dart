import 'bubble.dart';

class GameState {
  final List<Bubble> bubbles;
  final int score;
  final int level;
  final bool isGameOver;
  final bool isGameWon;

  GameState({
    required this.bubbles,
    this.score = 0,
    this.level = 1,
    this.isGameOver = false,
    this.isGameWon = false,
  });

  GameState copyWith({
    List<Bubble>? bubbles,
    int? score,
    int? level,
    bool? isGameOver,
    bool? isGameWon,
  }) {
    return GameState(
      bubbles: bubbles ?? this.bubbles,
      score: score ?? this.score,
      level: level ?? this.level,
      isGameOver: isGameOver ?? this.isGameOver,
      isGameWon: isGameWon ?? this.isGameWon,
    );
  }
} 