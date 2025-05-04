import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/services/audio_service.dart';
import 'core/services/score_service.dart';
import 'presentation/pages/menu_page.dart';
import 'package:flame/game.dart';
import 'presentation/flame/bubble_shooter_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Shooter Flame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlameMenuPage(),
    );
  }
}

class FlameMenuPage extends StatelessWidget {
  const FlameMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final game = BubbleShooterGame();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: GestureDetector(
                    onPanStart: (details) => game.onPanStart(details),
                    onPanUpdate: (details) => game.onPanUpdate(details),
                    onPanEnd: (details) => game.onPanEnd(details),
                    child: GameWidget(game: game),
                  ),
                ),
              ),
            );
          },
          child: const Text('Flame ile Bubble Shooter Oyna'),
        ),
      ),
    );
  }
}
