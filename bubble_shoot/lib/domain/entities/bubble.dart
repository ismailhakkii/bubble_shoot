import 'package:flutter/material.dart';

enum BubbleColor {
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
}

class Bubble {
  final BubbleColor color;
  final Offset position;
  final double radius;
  bool isPopped;

  Bubble({
    required this.color,
    required this.position,
    required this.radius,
    this.isPopped = false,
  });

  Color get bubbleColor {
    switch (color) {
      case BubbleColor.red:
        return Colors.red;
      case BubbleColor.blue:
        return Colors.blue;
      case BubbleColor.green:
        return Colors.green;
      case BubbleColor.yellow:
        return Colors.yellow;
      case BubbleColor.purple:
        return Colors.purple;
      case BubbleColor.orange:
        return Colors.orange;
    }
  }

  Bubble copyWith({
    BubbleColor? color,
    Offset? position,
    double? radius,
    bool? isPopped,
  }) {
    return Bubble(
      color: color ?? this.color,
      position: position ?? this.position,
      radius: radius ?? this.radius,
      isPopped: isPopped ?? this.isPopped,
    );
  }
} 