import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/bubble.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/game_repository.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/usecases/shoot_bubble_usecase.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/score_service.dart';

class GamePage extends StatefulWidget {
  final AudioService audioService;
  final ScoreService scoreService;

  const GamePage({
    super.key,
    required this.audioService,
    required this.scoreService,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GameRepository _gameRepository = GameRepositoryImpl();
  final ShootBubbleUseCase _shootBubbleUseCase = ShootBubbleUseCase(GameRepositoryImpl());
  late GameState _gameState;
  bool _isInitialized = false;
  Offset? _touchPosition;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    _gameState = await _gameRepository.initializeGame();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_gameState.isGameWon) {
      widget.audioService.playGameWon();
      _handleGameEnd();
      return _buildGameOverScreen('You Won!');
    }

    if (_gameState.isGameOver) {
      widget.audioService.playGameOver();
      _handleGameEnd();
      return _buildGameOverScreen('Game Over');
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildScoreBoard(),
              Expanded(
                child: GestureDetector(
                  onPanStart: _handlePanStart,
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: _handlePanEnd,
                  child: _buildGameBoard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Bubble Shooter',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetGame,
          ),
        ],
      ),
    );
  }

  Future<void> _handleGameEnd() async {
    if (await widget.scoreService.isHighScore(_gameState.score)) {
      await widget.scoreService.saveScore(_gameState.score);
    }
  }

  Widget _buildGameOverScreen(String message) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Score: ${_gameState.score}',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _resetGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Play Again',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Menu',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _touchPosition = details.globalPosition;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _touchPosition = details.globalPosition;
    });
  }

  void _handlePanEnd(DragEndDetails details) async {
    if (_touchPosition != null) {
      widget.audioService.playBubbleShoot();

      final shooterPosition = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height - 100,
      );
      
      final angle = _calculateAngle(shooterPosition, _touchPosition!);
      final newState = await _shootBubbleUseCase.execute(shooterPosition, angle);
      
      setState(() {
        _gameState = newState;
        _touchPosition = null;
      });

      if (newState.score > _gameState.score) {
        widget.audioService.playBubblePop();
      }
    }
  }

  double _calculateAngle(Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    return -atan2(dx, dy);
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreCard('Score', _gameState.score.toString()),
          _buildScoreCard('Level', _gameState.level.toString()),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Stack(
      children: [
        ..._gameState.bubbles.map((bubble) => _buildBubble(bubble)),
        _buildShooter(),
        if (_touchPosition != null) _buildAimLine(),
      ],
    );
  }

  Widget _buildBubble(Bubble bubble) {
    return Positioned(
      left: bubble.position.dx - bubble.radius,
      top: bubble.position.dy - bubble.radius,
      child: Container(
        width: bubble.radius * 2,
        height: bubble.radius * 2,
        decoration: BoxDecoration(
          color: bubble.bubbleColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bubble.bubbleColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShooter() {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 20,
      bottom: 20,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAimLine() {
    final shooterPosition = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height - 100,
    );
    final path = _calculateBouncedPath(
      shooterPosition,
      _touchPosition!,
      MediaQuery.of(context).size,
      maxBounces: 3,
    );
    return CustomPaint(
      painter: DashedAimLinePainter(path: path),
    );
  }

  List<Offset> _calculateBouncedPath(
    Offset start,
    Offset end,
    Size screenSize, {
    int maxBounces = 3,
  }) {
    final points = <Offset>[];
    points.add(start);
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    double angle = atan2(dy, dx);
    Offset current = start;
    double vx = cos(angle);
    double vy = sin(angle);
    for (int i = 0; i < maxBounces; i++) {
      double t;
      if (vx > 0) {
        t = (screenSize.width - current.dx) / vx;
      } else {
        t = -current.dx / vx;
      }
      double yAtWall = current.dy + vy * t;
      double xAtWall = vx > 0 ? screenSize.width : 0;
      if (yAtWall < 0) {
        double tTop = -current.dy / vy;
        points.add(Offset(current.dx + vx * tTop, 0));
        break;
      }
      points.add(Offset(xAtWall, yAtWall));
      current = Offset(xAtWall, yAtWall);
      vx = -vx;
    }
    return points;
  }

  Future<void> _resetGame() async {
    await _gameRepository.resetGame();
    await _initializeGame();
  }
}

class DashedAimLinePainter extends CustomPainter {
  final List<Offset> path;
  DashedAimLinePainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < path.length - 1; i++) {
      _drawDashedLine(canvas, path[i], path[i + 1], paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 6.0;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 