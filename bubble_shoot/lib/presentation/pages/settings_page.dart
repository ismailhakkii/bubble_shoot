import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/audio_service.dart';

class SettingsPage extends StatelessWidget {
  final AudioService audioService;

  const SettingsPage({
    super.key,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Settings',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSoundToggle(),
            const SizedBox(height: 20),
            _buildThemeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sound Effects',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            Switch(
              value: audioService.isSoundEnabled,
              onChanged: (value) => audioService.toggleSound(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming soon...',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
} 