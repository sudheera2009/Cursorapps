import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _sfxPool = {};
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hapticsEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.5;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
    _soundVolume = prefs.getDouble('soundVolume') ?? 0.8;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;

    await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgMusicPlayer.setVolume(_musicVolume);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setBool('hapticsEnabled', _hapticsEnabled);
    await prefs.setDouble('soundVolume', _soundVolume);
    await prefs.setDouble('musicVolume', _musicVolume);
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _saveSettings();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _bgMusicPlayer.stop();
    }
    _saveSettings();
  }

  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
    _saveSettings();
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
    _saveSettings();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _bgMusicPlayer.setVolume(_musicVolume);
    _saveSettings();
  }

  Future<void> playTap() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume * 0.5);
      await _sfxPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  Future<void> playDestroy() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
      await _sfxPlayer.play(AssetSource('sounds/destroy.mp3'));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  Future<void> playExplosion() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
      await _sfxPlayer.play(AssetSource('sounds/explosion.mp3'));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  Future<void> playCombo() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume * 0.7);
      await _sfxPlayer.play(AssetSource('sounds/combo.mp3'));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
      await _sfxPlayer.play(AssetSource('sounds/levelup.mp3'));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  Future<void> playVictory() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
      await _sfxPlayer.play(AssetSource('sounds/victory.mp3'));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  Future<void> playNuclear() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
      await _sfxPlayer.play(AssetSource('sounds/nuclear.mp3'));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  Future<void> playAchievement() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_soundVolume);
      await _sfxPlayer.play(AssetSource('sounds/achievement.mp3'));
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  Future<void> startBackgroundMusic(String mode) async {
    if (!_musicEnabled) return;
    try {
      await _bgMusicPlayer.stop();
      await _bgMusicPlayer.setVolume(_musicVolume);
      await _bgMusicPlayer.play(AssetSource('sounds/music_$mode.mp3'));
    } catch (e) {
      debugPrint('Music play error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _bgMusicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgMusicPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (_musicEnabled) {
      await _bgMusicPlayer.resume();
    }
  }

  void dispose() {
    _bgMusicPlayer.dispose();
    _sfxPlayer.dispose();
    for (var player in _sfxPool.values) {
      player.dispose();
    }
  }
}
