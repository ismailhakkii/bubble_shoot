import 'dart:math';
import 'package:flutter/material.dart';
import '../entities/bubble.dart';
import '../entities/game_state.dart';
import '../repositories/game_repository.dart';

class ShootBubbleUseCase {
  final GameRepository _repository;
  static const double _bubbleSpeed = 10.0;
  static const double _bubbleRadius = 20.0;

  ShootBubbleUseCase(this._repository);

  Future<GameState> execute(Offset position, double angle) async {
    final currentState = await _repository.getCurrentGameState();
    final newBubble = _createNewBubble(position, angle);
    final collisionPoint = _findCollisionPoint(currentState.bubbles, newBubble, angle);

    if (collisionPoint != null) {
      final updatedBubbles = List<Bubble>.from(currentState.bubbles)
        ..add(newBubble.copyWith(position: collisionPoint));

      final matchingBubbles = _findMatchingBubbles(updatedBubbles, collisionPoint);
      // Sadece 2 veya daha fazla aynı renkten balon varsa patlat
      if (matchingBubbles.length >= 2) {
        updatedBubbles.removeWhere((bubble) => matchingBubbles.contains(bubble));
      }
      // Tek balon varsa patlatma
      final newScore = matchingBubbles.length >= 2
          ? currentState.score + (matchingBubbles.length * 10)
          : currentState.score;
      final isGameWon = updatedBubbles.isEmpty;

      return GameState(
        bubbles: updatedBubbles,
        score: newScore,
        level: currentState.level,
        isGameWon: isGameWon,
      );
    }

    return currentState;
  }

  Bubble _createNewBubble(Offset position, double angle) {
    return Bubble(
      color: BubbleColor.values[Random().nextInt(BubbleColor.values.length)],
      position: position,
      radius: _bubbleRadius,
    );
  }

  // Gerçek çarpışma noktası: tavana veya en yakın balona çarptığında durur
  Offset? _findCollisionPoint(List<Bubble> existingBubbles, Bubble newBubble, double angle) {
    final screenWidth = 8 * _bubbleRadius * 2 + 50; // tahmini genişlik
    Offset pos = newBubble.position;
    double vx = sin(angle);
    double vy = -cos(angle);
    for (int step = 0; step < 1000; step++) {
      pos = Offset(pos.dx + vx * _bubbleRadius / 2, pos.dy + vy * _bubbleRadius / 2);
      // Duvara çarpınca sekme
      if (pos.dx <= _bubbleRadius) {
        pos = Offset(_bubbleRadius, pos.dy);
        vx = -vx;
      }
      if (pos.dx >= screenWidth - _bubbleRadius) {
        pos = Offset(screenWidth - _bubbleRadius, pos.dy);
        vx = -vx;
      }
      // Tavana çarptıysa
      if (pos.dy <= _bubbleRadius) {
        return Offset(pos.dx, _bubbleRadius);
      }
      // Başka bir balona çarptıysa
      for (final bubble in existingBubbles) {
        if ((bubble.position - pos).distance <= _bubbleRadius * 2 - 2) {
          // Çarpışma noktası, balonun hemen yanında
          final dx = pos.dx - bubble.position.dx;
          final dy = pos.dy - bubble.position.dy;
          final norm = sqrt(dx * dx + dy * dy);
          final px = bubble.position.dx + (dx / norm) * _bubbleRadius * 2;
          final py = bubble.position.dy + (dy / norm) * _bubbleRadius * 2;
          return Offset(px, py);
        }
      }
    }
    return null;
  }

  // Sadece çarpma noktasındaki balon ve komşuları için aynı renkten 2+ balon varsa patlat
  List<Bubble> _findMatchingBubbles(List<Bubble> bubbles, Offset position) {
    final matchingBubbles = <Bubble>[];
    final targetBubble = bubbles.firstWhere(
      (bubble) => (bubble.position - position).distance <= _bubbleRadius,
      orElse: () => Bubble(
        color: BubbleColor.red,
        position: Offset.zero,
        radius: _bubbleRadius,
        isPopped: true,
      ),
    );
    if ((targetBubble.position - position).distance > _bubbleRadius) return matchingBubbles;
    void findMatches(Bubble bubble) {
      if (matchingBubbles.contains(bubble)) return;
      matchingBubbles.add(bubble);
      for (final otherBubble in bubbles) {
        if (otherBubble != bubble &&
            otherBubble.color == bubble.color &&
            (otherBubble.position - bubble.position).distance <= _bubbleRadius * 2.1) {
          findMatches(otherBubble);
        }
      }
    }
    findMatches(targetBubble);
    return matchingBubbles;
  }
} 