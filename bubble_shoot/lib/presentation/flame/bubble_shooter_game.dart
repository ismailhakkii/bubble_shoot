import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/bubble_component.dart';
import 'components/shooter_component.dart';
import 'dart:math';
import 'components/moving_bubble_component.dart';

class BubbleShooterGame extends FlameGame {
  static const int rows = 8;
  static const int cols = 8;
  static const double bubbleRadius = 18.0;
  static const double padding = 8.0;

  final List<Color> bubbleColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  ShooterComponent? shooter;
  bool isAiming = false;
  Vector2? aimPosition;
  MovingBubbleComponent? movingBubble;
  int score = 0;
  int level = 1;
  bool showWin = false;
  bool isGameOver = false;
  double overlayAnim = 0; // 0: yok, 1: tam görünür
  Color? nextBubbleColor;
  bool nextIsRainbow = false;
  int shotsLeft = 0;
  bool nextIsExtraShot = false;

  @override
  Color backgroundColor() => const Color(0xFF4F8DFD);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(ScreenHitbox());
    _spawnBubbleGrid(rowCount: 8, colorCount: bubbleColors.length);
    _addShooter();
    _startLevel(8, bubbleColors.length);
  }

  void _spawnBubbleGrid({int rowCount = 8, int colorCount = 6}) {
    final random = Random();
    final startX = padding + bubbleRadius;
    final startY = padding + bubbleRadius;
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < cols; col++) {
        final x = startX + col * (bubbleRadius * 2 + padding);
        final y = startY + row * (bubbleRadius * 2 + padding);
        // %10 taş, %10 buz, %80 normal
        double roll = random.nextDouble();
        BubbleType type;
        Color color;
        if (roll < 0.10) {
          type = BubbleType.stone;
          color = Colors.grey;
        } else if (roll < 0.20) {
          type = BubbleType.ice;
          color = Colors.lightBlueAccent;
        } else {
          type = BubbleType.normal;
          color = bubbleColors[random.nextInt(colorCount)];
        }
        add(BubbleComponent(
          position: Vector2(x, y),
          radius: bubbleRadius,
          color: color,
          type: type,
        ));
      }
    }
  }

  void _addShooter() {
    shooter = ShooterComponent(
      radius: bubbleRadius,
      color: Colors.white,
      aimAngle: 0,
    );
    shooter!.position = Vector2(size.x / 2, size.y - bubbleRadius * 2 - padding);
    add(shooter!);
  }

  void _startLevel(int rowCount, int colorCount) {
    shotsLeft = rowCount * cols * 2;
    _generateNextBubble();
  }

  void _generateNextBubble() {
    final rand = Random();
    final roll = rand.nextDouble();
    if (roll < 0.12) {
      nextBubbleColor = null;
      nextIsRainbow = true;
      nextIsExtraShot = false;
    } else if (roll < 0.22) {
      nextBubbleColor = null;
      nextIsRainbow = false;
      nextIsExtraShot = true;
    } else {
      nextBubbleColor = bubbleColors[rand.nextInt(bubbleColors.length)];
      nextIsRainbow = false;
      nextIsExtraShot = false;
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (shooter != null) {
      shooter!.position = Vector2(canvasSize.x / 2, canvasSize.y - bubbleRadius * 2 - padding);
    }
  }

  void onPanStart(DragStartDetails details) {
    if (isGameOver) return;
    isAiming = true;
    aimPosition = Vector2(details.localPosition.dx, details.localPosition.dy);
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (isGameOver) return;
    aimPosition = Vector2(details.localPosition.dx, details.localPosition.dy);
    final center = Vector2(size.x / 2, size.y - bubbleRadius * 2 - padding);
    final dx = aimPosition!.x - center.x;
    final dy = aimPosition!.y - center.y;
    if (shooter != null) {
      shooter!.aimAngle = atan2(dx, dy);
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (isGameOver) return;
    isAiming = false;
    aimPosition = null;
    if (movingBubble == null && shooter != null && shotsLeft > 0) {
      final angle = shooter!.aimAngle;
      final velocity = Vector2(-sin(angle), -cos(angle));
      Color color;
      if (nextIsRainbow) {
        color = Colors.white;
      } else if (nextIsExtraShot) {
        color = Colors.orangeAccent;
      } else {
        color = nextBubbleColor ?? Colors.white;
      }
      final start = Vector2(size.x / 2, size.y - bubbleRadius * 2 - padding);
      movingBubble = MovingBubbleComponent(
        position: start.clone(),
        radius: bubbleRadius,
        color: color,
        velocity: velocity,
      );
      add(movingBubble!);
      if (!nextIsExtraShot) {
        shotsLeft--;
      }
      _generateNextBubble();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Skor, seviye ve kalan atış göster
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score   Level: $level   Shots: $shotsLeft',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(16, 16));
    // Sıradaki balon göstergesi
    final nextPaint = Paint()
      ..color = nextIsRainbow
          ? Colors.white
          : nextIsExtraShot
              ? Colors.orangeAccent
              : (nextBubbleColor ?? Colors.white)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.x - 40, 40),
      bubbleRadius,
      nextPaint,
    );
    if (nextIsRainbow) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      for (int i = 0; i < bubbleColors.length; i++) {
        arcPaint.color = bubbleColors[i];
        canvas.drawArc(
          Rect.fromCircle(center: Offset(size.x - 40, 40), radius: bubbleRadius + 2),
          i * pi / 3,
          pi / 3,
          false,
          arcPaint,
        );
      }
    } else if (nextIsExtraShot) {
      final plusPainter = TextPainter(
        text: const TextSpan(
          text: '+1',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      plusPainter.paint(canvas, Offset(size.x - 40 - plusPainter.width / 2, 40 - plusPainter.height / 2));
    }
    // Game Over overlay animasyonlu
    if (isGameOver) {
      final opacity = overlayAnim.clamp(0, 1) as double;
      final scale = 0.7 + 0.3 * opacity;
      final overPainter = TextPainter(
        text: TextSpan(
          text: 'Game Over\nScore: $score\n(Tap to Restart)',
          style: TextStyle(
            color: Colors.red.withOpacity(opacity),
            fontSize: 40 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.x - 32);
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2 - overPainter.height);
      canvas.scale(scale, scale);
      overPainter.paint(canvas, Offset(-overPainter.width / 2, 0));
      canvas.restore();
      return;
    }
    // Seviye geçişi overlay animasyonlu
    if (showWin) {
      final opacity = overlayAnim.clamp(0, 1) as double;
      final scale = 0.7 + 0.3 * opacity;
      final winPainter = TextPainter(
        text: TextSpan(
          text: 'Level Up!',
          style: TextStyle(
            color: Colors.yellow.withOpacity(opacity),
            fontSize: 48 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2 - winPainter.height);
      canvas.scale(scale, scale);
      winPainter.paint(canvas, Offset(-winPainter.width / 2, 0));
      canvas.restore();
    }
    // Nişan alma sırasında kesikli çizgi çiz
    if (isAiming && aimPosition != null) {
      final center = Offset(size.x / 2, size.y - bubbleRadius * 2 - padding);
      final aim = Offset(aimPosition!.x, aimPosition!.y);
      _drawDashedLine(canvas, center, aim, Colors.white);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    const dashWidth = 10.0;
    const dashSpace = 6.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;
    final totalLength = (end - start).distance;
    final direction = (end - start) / totalLength;
    double distance = 0;
    while (distance < totalLength) {
      final from = start + direction * distance;
      final to = start + direction * min(distance + dashWidth, totalLength);
      canvas.drawLine(from, to, paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Oyun sonu kontrolü: atış hakkı biterse
    if (!isGameOver && shotsLeft <= 0) {
      isGameOver = true;
      overlayAnim = 0;
    }
    // Oyun sonu kontrolü: herhangi bir balon alt çizgiye ulaşırsa
    if (!isGameOver) {
      final loseLine = size.y - bubbleRadius * 4 - padding * 2;
      for (final bubble in children.whereType<BubbleComponent>()) {
        if (bubble.position.y + bubble.radius >= loseLine) {
          isGameOver = true;
          overlayAnim = 0;
          break;
        }
      }
    }
    if (isGameOver) {
      overlayAnim += dt * 2;
      if (overlayAnim > 1) overlayAnim = 1;
      return;
    }
    // Seviye geçişi: Tüm balonlar bittiğinde yeni seviye başlat
    if (children.whereType<BubbleComponent>().isEmpty && !showWin) {
      showWin = true;
      overlayAnim = 0;
      Future.delayed(const Duration(seconds: 1), () {
        level++;
        score += 100; // bonus
        _spawnBubbleGrid(rowCount: 8 + level, colorCount: bubbleColors.length < 6 ? bubbleColors.length + 1 : 6);
        showWin = false;
        overlayAnim = 0;
      });
    }
    if (showWin) {
      overlayAnim += dt * 2;
      if (overlayAnim > 1) overlayAnim = 1;
    }
    // Hareketli top varsa çarpışma kontrolü yap
    if (movingBubble != null) {
      // Tüm grid balonlarını bul
      final gridBubbles = children.whereType<BubbleComponent>().toList();
      bool collided = false;
      for (final bubble in gridBubbles) {
        final dist = (bubble.position - movingBubble!.position).length;
        if (dist <= bubble.radius + movingBubble!.radius) {
          // Çarpışma oldu, yeni balonu ekle
          _addAndCheckPop(movingBubble!.position.clone(), movingBubble!.color);
          remove(movingBubble!);
          movingBubble = null;
          collided = true;
          break;
        }
      }
      // Tavana çarptıysa
      if (!collided && movingBubble != null && movingBubble!.position.y - movingBubble!.radius <= 0) {
        _addAndCheckPop(movingBubble!.position.clone(), movingBubble!.color);
        remove(movingBubble!);
        movingBubble = null;
      }
      // Eğer hareketli top durduysa, onu kaldır
      if (movingBubble != null &&
          (movingBubble!.velocity.x == 0 && movingBubble!.velocity.y == 0)) {
        remove(movingBubble!);
        movingBubble = null;
      }
    }
  }

  void _addAndCheckPop(Vector2 pos, Color color) {
    final isRainbow = color == Colors.white;
    final isExtraShot = color == Colors.orangeAccent;
    BubbleType type = BubbleType.normal;
    if (color == Colors.grey) type = BubbleType.stone;
    if (color == Colors.lightBlueAccent) type = BubbleType.ice;
    final newBubble = BubbleComponent(
      position: pos,
      radius: bubbleRadius,
      color: isRainbow ? Colors.white : isExtraShot ? Colors.orangeAccent : color,
      type: type,
    );
    add(newBubble);
    // Patlama kontrolü
    final gridBubbles = children.whereType<BubbleComponent>().toList() + [newBubble];
    List<BubbleComponent> popped;
    if (isRainbow) {
      popped = _findLargestConnectedGroup(newBubble, gridBubbles);
    } else {
      popped = _findConnectedBubbles(newBubble, gridBubbles);
    }
    // Taş balonlar asla patlamaz, buz balonlar 2 vuruşta patlar
    popped = popped.where((b) => b.type != BubbleType.stone).toList();
    for (final b in popped) {
      if (b.type == BubbleType.ice) {
        b.hitCount++;
        if (b.hitCount < 2) continue;
      }
      b.pop();
    }
    if (popped.isNotEmpty) {
      score += popped.length * 10;
      // Asılı kalan balonları bul ve düşür
      final floating = _findFloatingBubbles();
      for (final b in floating) {
        b.pop();
      }
      score += floating.length * 15; // Düşen balonlar için ekstra puan
    }
    if (isExtraShot) {
      shotsLeft++;
    }
  }

  // DFS ile bağlı aynı renkten balonları bul
  List<BubbleComponent> _findConnectedBubbles(BubbleComponent start, List<BubbleComponent> all) {
    final visited = <BubbleComponent>[];
    void dfs(BubbleComponent bubble) {
      visited.add(bubble);
      for (final other in all) {
        if (!visited.contains(other) &&
            other.color == bubble.color &&
            (other.position - bubble.position).length <= bubble.radius * 2.1) {
          dfs(other);
        }
      }
    }
    dfs(start);
    return visited;
  }

  // Rainbow balon için: en büyük bağlı grup
  List<BubbleComponent> _findLargestConnectedGroup(BubbleComponent start, List<BubbleComponent> all) {
    List<BubbleComponent> largest = [];
    for (final color in bubbleColors) {
      final group = _findConnectedBubbles(
        BubbleComponent(position: start.position, radius: start.radius, color: color),
        all,
      );
      if (group.length > largest.length) largest = group;
    }
    return largest;
  }

  // Tavana bağlı olmayan balonları bul
  List<BubbleComponent> _findFloatingBubbles() {
    final all = children.whereType<BubbleComponent>().toList();
    final connected = <BubbleComponent>[];
    // Tavana temas eden balonlardan DFS ile bağlı olanları bul
    for (final b in all) {
      if ((b.position.y - b.radius) <= (padding + 2)) {
        _dfsFloating(b, all, connected);
      }
    }
    // Bağlı olmayanlar floating
    return all.where((b) => !connected.contains(b) && b.type != BubbleType.stone).toList();
  }

  void _dfsFloating(BubbleComponent bubble, List<BubbleComponent> all, List<BubbleComponent> connected) {
    if (connected.contains(bubble)) return;
    connected.add(bubble);
    for (final other in all) {
      if (!connected.contains(other) &&
          (other.position - bubble.position).length <= bubble.radius * 2.1) {
        _dfsFloating(other, all, connected);
      }
    }
  }

  void onTapDown(TapDownDetails details) {
    if (isGameOver) {
      // Oyunu sıfırla
      score = 0;
      level = 1;
      isGameOver = false;
      showWin = false;
      // Tüm balonları ve hareketli topu sil
      final toRemove = children.where((c) => c is BubbleComponent || c is MovingBubbleComponent).toList();
      for (final c in toRemove) {
        remove(c);
      }
      _spawnBubbleGrid(rowCount: 8, colorCount: bubbleColors.length);
    }
  }
} 