import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MovingBubbleComponent extends CircleComponent {
  final Color color;
  Vector2 velocity;
  final double speed;

  MovingBubbleComponent({
    required Vector2 position,
    required double radius,
    required this.color,
    required this.velocity,
    this.speed = 300,
  }) : super(
          position: position,
          radius: radius,
        );

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset.zero, radius, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * speed * dt;
    // Duvara çarpınca sekme
    final gameSize = (parent as FlameGame).size;
    if (position.x - radius <= 0 && velocity.x < 0) {
      velocity.x = -velocity.x;
    }
    if (position.x + radius >= gameSize.x && velocity.x > 0) {
      velocity.x = -velocity.x;
    }
    // Tavana çarptıysa (ileride balonlara çarpma da eklenecek)
    if (position.y - radius <= 0 && velocity.y < 0) {
      velocity.y = 0;
      velocity.x = 0;
    }
  }
} 