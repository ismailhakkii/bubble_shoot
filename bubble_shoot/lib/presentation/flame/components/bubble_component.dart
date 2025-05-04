import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum BubbleType { normal, stone, ice }

class BubbleComponent extends CircleComponent {
  final Color color;
  final BubbleType type;
  bool isPopping = false;
  int hitCount = 0; // For ice

  BubbleComponent({
    required Vector2 position,
    required double radius,
    required this.color,
    this.type = BubbleType.normal,
  }) : super(
          position: position,
          radius: radius,
        );

  @override
  void render(Canvas canvas) {
    Color drawColor = color;
    if (type == BubbleType.stone) drawColor = Colors.grey[700]!;
    if (type == BubbleType.ice) drawColor = Colors.lightBlueAccent;
    final paint = Paint()
      ..color = drawColor.withOpacity(isPopping ? 0.5 : 1.0);
    canvas.save();
    if (isPopping) {
      canvas.scale(0.7, 0.7);
    }
    canvas.drawCircle(Offset.zero, radius, paint);
    // Ice crack
    if (type == BubbleType.ice && hitCount == 1) {
      final crackPaint = Paint()
        ..color = Colors.blue[900]!
        ..strokeWidth = 2;
      canvas.drawLine(Offset(-radius / 2, 0), Offset(radius / 2, 0), crackPaint);
      canvas.drawLine(Offset(0, -radius / 2), Offset(0, radius / 2), crackPaint);
    }
    canvas.restore();
  }

  Future<void> pop() async {
    isPopping = true;
    await Future.delayed(const Duration(milliseconds: 180));
    removeFromParent();
  }
} 