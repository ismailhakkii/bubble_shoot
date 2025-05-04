import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ShooterComponent extends PositionComponent {
  final double radius;
  final Color color;
  double aimAngle;

  ShooterComponent({
    required this.radius,
    required this.color,
    this.aimAngle = 0,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    // Draw the shooter circle
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, paint);
    // Draw the aim line
    final aimLength = radius * 3;
    final center = Offset(size.x / 2, size.y / 2);
    final aimEnd = Offset(
      center.dx + aimLength * -sin(aimAngle),
      center.dy - aimLength * cos(aimAngle),
    );
    final aimPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(center, aimEnd, aimPaint);
  }

  @override
  Future<void> onLoad() async {
    size = Vector2(radius * 2, radius * 2);
    anchor = Anchor.center;
  }
} 