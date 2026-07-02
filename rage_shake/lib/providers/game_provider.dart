import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/destruction_mode.dart';
import '../models/game_state.dart';
import '../core/theme.dart';

class GameProvider extends ChangeNotifier {
  GameSession? _currentSession;
  UserProgress _userProgress = UserProgress();
  final Random _random = Random();
  Timer? _gameTimer;
  Timer? _comboTimer;
  
  List<FloatingDamage> floatingDamages = [];
  List<Particle> particles = [];
  double _currentShakeIntensity = 0.0;
  bool _isShaking = false;

  GameSession? get currentSession => _currentSession;
  UserProgress get userProgress => _userProgress;
  double get shakeIntensity => _currentShakeIntensity;
  bool get isShaking => _isShaking;
  RageLevel get currentRageLevel => 
      _currentSession != null ? RageColors.getLevel(_currentSession!.rageLevel) : RageLevel.calm;

  GameProvider() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _userProgress = UserProgress(
      totalDestruction: prefs.getInt('totalDestruction') ?? 0,
      totalObjects: prefs.getInt('totalObjects') ?? 0,
      totalSessions: prefs.getInt('totalSessions') ?? 0,
      currentLevel: prefs.getInt('currentLevel') ?? 1,
      currentXP: prefs.getInt('currentXP') ?? 0,
      dailyDestruction: prefs.getInt('dailyDestruction') ?? 0,
    );
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalDestruction', _userProgress.totalDestruction);
    await prefs.setInt('totalObjects', _userProgress.totalObjects);
    await prefs.setInt('totalSessions', _userProgress.totalSessions);
    await prefs.setInt('currentLevel', _userProgress.currentLevel);
    await prefs.setInt('currentXP', _userProgress.currentXP);
    await prefs.setInt('dailyDestruction', _userProgress.dailyDestruction);
  }

  void startGame(DestructionMode mode) {
    _currentSession = GameSession(mode: mode, isActive: true);
    floatingDamages.clear();
    particles.clear();
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession != null && _currentSession!.isActive) {
        _currentSession!.duration = DateTime.now().difference(_currentSession!.startTime);
        notifyListeners();
      }
    });
    
    notifyListeners();
  }

  void endGame() {
    if (_currentSession != null) {
      _currentSession!.isActive = false;
      _userProgress.recordSession(_currentSession!);
      _saveProgress();
    }
    _gameTimer?.cancel();
    _comboTimer?.cancel();
    notifyListeners();
  }

  void processShake(double x, double y, double z) {
    if (_currentSession == null || !_currentSession!.isActive) return;

    final magnitude = sqrt(x * x + y * y + z * z);
    final normalizedMagnitude = ((magnitude - 9.8).abs() / 30).clamp(0.0, 1.0);
    
    _currentShakeIntensity = normalizedMagnitude;
    _isShaking = normalizedMagnitude > 0.1;
    
    _currentSession!.updateRage(normalizedMagnitude);

    if (_isShaking) {
      _resetComboTimer();
      
      if (_random.nextDouble() < normalizedMagnitude * 0.3) {
        _destroyRandomObject();
      }
      
      _spawnParticles(normalizedMagnitude);
      _triggerHaptic(normalizedMagnitude);
    }

    notifyListeners();
  }

  void _destroyRandomObject() {
    if (_currentSession == null) return;
    
    final objects = _currentSession!.mode.objects;
    final object = objects[_random.nextInt(objects.length)];
    
    final rageMultiplier = 1 + (_currentSession!.rageLevel * 2);
    final damage = (object.baseValue * rageMultiplier).toInt();
    
    _currentSession!.addDamage(damage);
    
    final screenWidth = 300.0;
    final screenHeight = 500.0;
    final position = Offset(
      _random.nextDouble() * screenWidth,
      _random.nextDouble() * screenHeight,
    );
    
    floatingDamages.add(FloatingDamage(
      position: position,
      damage: damage,
      createdAt: DateTime.now(),
    ));
    
    for (int i = 0; i < 5 + _random.nextInt(10); i++) {
      particles.add(Particle(
        position: position,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 10,
          (_random.nextDouble() - 0.5) * 10,
        ),
        color: _currentSession!.mode.color,
        size: 3 + _random.nextDouble() * 5,
        createdAt: DateTime.now(),
      ));
    }
  }

  void _spawnParticles(double intensity) {
    final count = (intensity * 5).toInt();
    for (int i = 0; i < count; i++) {
      particles.add(Particle(
        position: Offset(
          _random.nextDouble() * 300,
          _random.nextDouble() * 500,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 5,
          -_random.nextDouble() * 5,
        ),
        color: RageColors.lerpPrimary(_currentSession?.rageLevel ?? 0),
        size: 2 + _random.nextDouble() * 3,
        createdAt: DateTime.now(),
      ));
    }
  }

  void _triggerHaptic(double intensity) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      if (intensity > 0.7) {
        Vibration.vibrate(duration: 50, amplitude: 255);
      } else if (intensity > 0.4) {
        Vibration.vibrate(duration: 30, amplitude: 180);
      } else if (intensity > 0.2) {
        Vibration.vibrate(duration: 20, amplitude: 100);
      }
    }
  }

  void _resetComboTimer() {
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_currentSession != null) {
        _currentSession!.resetCombo();
        notifyListeners();
      }
    });
  }

  void updateParticles() {
    final now = DateTime.now();
    
    floatingDamages.removeWhere((d) => 
      now.difference(d.createdAt).inMilliseconds > 1000);
    
    particles.removeWhere((p) => 
      now.difference(p.createdAt).inMilliseconds > 2000);
    
    for (var particle in particles) {
      particle.position = Offset(
        particle.position.dx + particle.velocity.dx,
        particle.position.dy + particle.velocity.dy,
      );
      particle.velocity = Offset(
        particle.velocity.dx * 0.98,
        particle.velocity.dy + 0.2,
      );
    }
    
    notifyListeners();
  }

  void manualDestroy(Offset position) {
    if (_currentSession == null || !_currentSession!.isActive) return;

    final objects = _currentSession!.mode.objects;
    final object = objects[_random.nextInt(objects.length)];
    
    final rageMultiplier = 1 + (_currentSession!.rageLevel * 2);
    final damage = (object.baseValue * rageMultiplier).toInt();
    
    _currentSession!.addDamage(damage);
    _resetComboTimer();
    
    floatingDamages.add(FloatingDamage(
      position: position,
      damage: damage,
      createdAt: DateTime.now(),
    ));
    
    for (int i = 0; i < 10 + _random.nextInt(15); i++) {
      particles.add(Particle(
        position: position,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 15,
          (_random.nextDouble() - 0.5) * 15,
        ),
        color: _currentSession!.mode.color,
        size: 4 + _random.nextDouble() * 8,
        createdAt: DateTime.now(),
      ));
    }
    
    _triggerHaptic(0.8);
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _comboTimer?.cancel();
    super.dispose();
  }
}

class FloatingDamage {
  Offset position;
  final int damage;
  final DateTime createdAt;

  FloatingDamage({
    required this.position,
    required this.damage,
    required this.createdAt,
  });

  String get formattedDamage {
    if (damage >= 1000000) {
      return '+\$${(damage / 1000000).toStringAsFixed(1)}M';
    } else if (damage >= 1000) {
      return '+\$${(damage / 1000).toStringAsFixed(1)}K';
    }
    return '+\$$damage';
  }

  double get opacity {
    final age = DateTime.now().difference(createdAt).inMilliseconds;
    return (1 - age / 1000).clamp(0.0, 1.0);
  }

  double get offsetY {
    final age = DateTime.now().difference(createdAt).inMilliseconds;
    return -age / 20;
  }
}

class Particle {
  Offset position;
  Offset velocity;
  final Color color;
  final double size;
  final DateTime createdAt;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.createdAt,
  });

  double get opacity {
    final age = DateTime.now().difference(createdAt).inMilliseconds;
    return (1 - age / 2000).clamp(0.0, 1.0);
  }
}
