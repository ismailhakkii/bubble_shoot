import 'package:flutter/material.dart';
import '../entities/game_state.dart';

abstract class GameRepository {
  Future<GameState> initializeGame();
  Future<GameState> shootBubble(Offset position, double angle);
  Future<GameState> getCurrentGameState();
  Future<void> saveGameState(GameState state);
  Future<void> resetGame();
} 