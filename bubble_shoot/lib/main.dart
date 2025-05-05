import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/services/audio_service.dart' as core_audio;
import 'core/services/score_service.dart';
import 'presentation/pages/menu_page.dart';
import 'package:flame/game.dart';
import 'presentation/flame/bubble_shooter_game.dart';
import 'presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final audioService = core_audio.AudioService();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    setState(() {
      _showOnboarding = !seen;
    });
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }
    return MaterialApp(
      title: 'Bubble Shooter Flame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _showOnboarding!
          ? OnboardingPage(onFinish: _finishOnboarding)
          : FlameMenuPage(audioService: audioService),
    );
  }
}

class FlameMenuPage extends StatefulWidget {
  final core_audio.AudioService audioService;
  const FlameMenuPage({super.key, required this.audioService});

  @override
  State<FlameMenuPage> createState() => _FlameMenuPageState();
}

class _FlameMenuPageState extends State<FlameMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
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
                        onTapDown: (details) => game.onTapDown(details),
                        child: GameWidget(game: game),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Flame ile Bubble Shooter Oyna'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnboardingPage(
                      onFinish: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
              child: const Text('Yardım / Nasıl Oynanır?'),
            ),
            const SizedBox(height: 24),
            IconButton(
              icon: Icon(widget.audioService.isSoundEnabled ? Icons.volume_up : Icons.volume_off, size: 32),
              onPressed: () {
                setState(() {
                  widget.audioService.toggleSound();
                });
              },
              tooltip: widget.audioService.isSoundEnabled ? 'Sesi Kapat' : 'Sesi Aç',
            ),
          ],
        ),
      ),
    );
  }
}
