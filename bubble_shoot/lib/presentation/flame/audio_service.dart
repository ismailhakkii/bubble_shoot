import 'package:flame_audio/flame_audio.dart';

class AudioService {
  bool isMuted = false;

  Future<void> playPop() async {
    if (!isMuted) await FlameAudio.play('pop.mp3');
  }

  Future<void> playShoot() async {
    if (!isMuted) await FlameAudio.play('shoot.mp3');
  }

  Future<void> playLevelUp() async {
    if (!isMuted) await FlameAudio.play('level_up.mp3');
  }

  Future<void> playGameOver() async {
    if (!isMuted) await FlameAudio.play('game_over.mp3');
  }

  Future<void> playMusic() async {
    if (!isMuted) await FlameAudio.bgm.play('bgm.mp3', volume: 0.5);
  }

  Future<void> stopMusic() async {
    await FlameAudio.bgm.stop();
  }

  void mute() {
    isMuted = true;
    stopMusic();
  }

  void unmute() {
    isMuted = false;
    playMusic();
  }
} 