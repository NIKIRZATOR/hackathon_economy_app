import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  double _musicVolume = 1.0;
  double _sfxVolume = 1.0;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // Музыка
  Future<void> playMusic(String fileName, {bool loop = true}) async {
    if (!_musicEnabled) return;

    await _musicPlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release);
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.play(AssetSource('audio/music/$fileName'));
  }
  
  void stopMusic() {
    _musicPlayer.stop();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_musicEnabled) {
      await _musicPlayer.resume();
    }
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  // Звуковые эффекты
  Future<void> playSfx(String fileName) async {
    if (!_sfxEnabled) return;

    final player = AudioPlayer();
    await player.setVolume(_sfxVolume);
    await player.play(AssetSource('audio/sfx/$fileName'));
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }
}