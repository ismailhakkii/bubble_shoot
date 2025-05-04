import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static const String _soundEnabledKey = 'sound_enabled';
  final AudioPlayer _player = AudioPlayer();
  bool _isSoundEnabled = true;

  AudioService() {
    _loadSoundPreference();
  }

  Future<void> _loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, _isSoundEnabled);
  }

  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> playBubblePop() async {
    if (_isSoundEnabled) {
      try {
        await _player.play(AssetSource('sounds/pop.mp3'));
      } catch (e) {
        // Ignore sound errors
      }
    }
  }

  Future<void> playBubbleShoot() async {
    if (_isSoundEnabled) {
      try {
        await _player.play(AssetSource('sounds/shoot.mp3'));
      } catch (e) {
        // Ignore sound errors
      }
    }
  }

  Future<void> playGameOver() async {
    if (_isSoundEnabled) {
      try {
        await _player.play(AssetSource('sounds/game_over.mp3'));
      } catch (e) {
        // Ignore sound errors
      }
    }
  }

  Future<void> playGameWon() async {
    if (_isSoundEnabled) {
      try {
        await _player.play(AssetSource('sounds/win.mp3'));
      } catch (e) {
        // Ignore sound errors
      }
    }
  }

  Future<void> playLevelUp() async {
    if (_isSoundEnabled) {
      try {
        await _player.play(AssetSource('sounds/level_up.mp3'));
      } catch (e) {
        // Ignore sound errors
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
} 