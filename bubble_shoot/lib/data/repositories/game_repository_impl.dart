import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/bubble.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  GameState? _currentState;

  @override
  Future<GameState> initializeGame() async {
    final bubbles = _generateInitialBubbles();
    _currentState = GameState(
      bubbles: bubbles,
      score: 0,
      level: 1,
      isGameOver: false,
      isGameWon: false,
    );
    return _currentState!;
  }

  @override
  Future<GameState> shootBubble(Offset position, double angle) async {
    if (_currentState == null) {
      await initializeGame();
    }

    // TODO: Implement bubble shooting logic
    return _currentState!;
  }

  @override
  Future<GameState> getCurrentGameState() async {
    if (_currentState == null) {
      await initializeGame();
    }
    return _currentState!;
  }

  @override
  Future<void> saveGameState(GameState state) async {
    _currentState = state;
  }

  @override
  Future<void> resetGame() async {
    await initializeGame();
  }

  List<Bubble> _generateInitialBubbles() {
    final bubbles = <Bubble>[];
    const rows = 8;
    const cols = 8;
    const bubbleRadius = 20.0;
    const startX = 50.0;
    const startY = 50.0;
    final random = Random();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = startX + (col * bubbleRadius * 2);
        final y = startY + (row * bubbleRadius * 2);
        final color = BubbleColor.values[random.nextInt(BubbleColor.values.length)];
        bubbles.add(
          Bubble(
            color: color,
            position: Offset(x, y),
            radius: bubbleRadius,
          ),
        );
      }
    }
    return bubbles;
  }
} 