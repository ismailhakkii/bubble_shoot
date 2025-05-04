import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'game_page.dart';
import 'settings_page.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/score_service.dart';

class MenuPage extends StatelessWidget {
  final AudioService audioService;
  final ScoreService scoreService;

  const MenuPage({
    super.key,
    required this.audioService,
    required this.scoreService,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bubble Shoot',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.milliseconds)
                    .slideY(begin: -0.3, end: 0),
                const SizedBox(height: 50),
                _buildButton(
                  context,
                  'Play',
                  () => _navigateToGame(context),
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context,
                  'Settings',
                  () => _navigateToSettings(context),
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  context,
                  'High Scores',
                  Icons.leaderboard,
                  () => _showHighScores(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: GoogleFonts.poppins(fontSize: 20),
      ),
      child: Text(text),
    ).animate().fadeIn(duration: 500.milliseconds).slideX(begin: -0.3, end: 0);
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        backgroundColor: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.milliseconds).slideX(begin: -0.3, end: 0);
  }

  void _navigateToGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          audioService: audioService,
          scoreService: scoreService,
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          audioService: audioService,
        ),
      ),
    );
  }

  void _showHighScores(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<int>>(
        future: scoreService.getHighScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final scores = snapshot.data ?? [];
          return AlertDialog(
            title: Text('High Scores', style: GoogleFonts.poppins()),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: scores.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text(
                      '${index + 1}.',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Text(
                      scores[index].toString(),
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: GoogleFonts.poppins()),
              ),
            ],
          );
        },
      ),
    );
  }
} 