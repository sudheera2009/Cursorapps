import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/destruction_mode.dart';
import '../models/game_state.dart';
import '../models/achievement.dart';
import '../models/daily_challenge.dart';
import '../core/theme.dart';
import '../services/sound_service.dart';

class GameProvider extends ChangeNotifier {
  GameSession? _currentSession;
  UserProgress _userProgress = UserProgress();
  final Random _random = Random();
  final SoundService _soundService = SoundService();
  Timer? _gameTimer;
  Timer? _comboTimer;
  
  List<FloatingDamage> floatingDamages = [];
  List<Particle> particles = [];
  double _currentShakeIntensity = 0.0;
  bool _isShaking = false;
  bool _reachedNuclearThisSession = false;
  int _previousLevel = 1;
  
  // Daily challenge tracking
  List<DailyChallenge> _todaysChallenges = [];
  Map<String, int> _dailyChallengeProgress = {};
  Set<String> _completedDailyChallenges = {};
  int _dailySessions = 0;
  int _dailyObjects = 0;
  int _dailyDamage = 0;
  int _dailyMaxCombo = 0;
  bool _dailyReachedNuclear = false;
  Set<String> _dailyModesPlayed = {};
  
  // Newly unlocked achievements (to show notifications)
  List<Achievement> _newlyUnlockedAchievements = [];

  GameSession? get currentSession => _currentSession;
  UserProgress get userProgress => _userProgress;
  double get shakeIntensity => _currentShakeIntensity;
  bool get isShaking => _isShaking;
  RageLevel get currentRageLevel => 
      _currentSession != null ? RageColors.getLevel(_currentSession!.rageLevel) : RageLevel.calm;
  List<DailyChallenge> get todaysChallenges => _todaysChallenges;
  Map<String, int> get dailyChallengeProgress => _dailyChallengeProgress;
  Set<String> get completedDailyChallenges => _completedDailyChallenges;
  List<Achievement> get newlyUnlockedAchievements => _newlyUnlockedAchievements;

  GameProvider() {
    _loadProgress();
  }

  void clearNewAchievements() {
    _newlyUnlockedAchievements.clear();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load basic progress
    _userProgress = UserProgress(
      totalDestruction: prefs.getInt('totalDestruction') ?? 0,
      totalObjects: prefs.getInt('totalObjects') ?? 0,
      totalSessions: prefs.getInt('totalSessions') ?? 0,
      currentLevel: prefs.getInt('currentLevel') ?? 1,
      currentXP: prefs.getInt('currentXP') ?? 0,
      dailyDestruction: prefs.getInt('dailyDestruction') ?? 0,
      lastPlayDate: DateTime.tryParse(prefs.getString('lastPlayDate') ?? '') ?? DateTime.now(),
    );
    
    // Load achievements
    final achievementsList = prefs.getStringList('achievements') ?? [];
    _userProgress.achievements = achievementsList;
    
    // Load mode high scores
    final highScoresJson = prefs.getString('modeHighScores');
    if (highScoresJson != null) {
      final Map<String, dynamic> decoded = json.decode(highScoresJson);
      _userProgress.modeHighScores = decoded.map((k, v) => MapEntry(k, v as int));
    }
    
    // Load daily streak
    _userProgress.dailyStreak = prefs.getInt('dailyStreak') ?? 0;
    
    // Load modes played (for all_modes achievement)
    final modesPlayedList = prefs.getStringList('modesPlayed') ?? [];
    _userProgress.modesPlayed = modesPlayedList.toSet();
    
    // Check for daily reset
    await _checkDailyReset();
    
    // Load today's challenges
    _loadTodaysChallenges();
    
    _previousLevel = _userProgress.currentLevel;
    notifyListeners();
  }

  Future<void> _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPlay = _userProgress.lastPlayDate;
    final lastPlayDay = DateTime(lastPlay.year, lastPlay.month, lastPlay.day);
    
    if (today.isAfter(lastPlayDay)) {
      // Check streak
      final difference = today.difference(lastPlayDay).inDays;
      if (difference == 1) {
        // Consecutive day - increment streak
        _userProgress.dailyStreak++;
      } else if (difference > 1) {
        // Streak broken
        _userProgress.dailyStreak = 0;
      }
      
      // Reset daily stats
      _userProgress.dailyDestruction = 0;
      _dailySessions = 0;
      _dailyObjects = 0;
      _dailyDamage = 0;
      _dailyMaxCombo = 0;
      _dailyReachedNuclear = false;
      _dailyModesPlayed.clear();
      _completedDailyChallenges.clear();
      _dailyChallengeProgress.clear();
      
      // Update last play date
      _userProgress.lastPlayDate = now;
      
      await prefs.setInt('dailyStreak', _userProgress.dailyStreak);
      await prefs.setString('lastPlayDate', now.toIso8601String());
      await prefs.setInt('dailyDestruction', 0);
      await prefs.setInt('dailySessions', 0);
      await prefs.setStringList('completedDailyChallenges', []);
    } else {
      // Same day - load daily progress
      _dailySessions = prefs.getInt('dailySessions') ?? 0;
      _dailyObjects = prefs.getInt('dailyObjects') ?? 0;
      _dailyDamage = prefs.getInt('dailyDamage') ?? 0;
      _dailyMaxCombo = prefs.getInt('dailyMaxCombo') ?? 0;
      _dailyReachedNuclear = prefs.getBool('dailyReachedNuclear') ?? false;
      _completedDailyChallenges = (prefs.getStringList('completedDailyChallenges') ?? []).toSet();
      _dailyModesPlayed = (prefs.getStringList('dailyModesPlayed') ?? []).toSet();
    }
  }

  void _loadTodaysChallenges() {
    _todaysChallenges = DailyChallenges.getDailyChallenges(DateTime.now());
    _updateChallengeProgress();
  }

  void _updateChallengeProgress() {
    _dailyChallengeProgress.clear();
    for (final challenge in _todaysChallenges) {
      int progress = 0;
      switch (challenge.type) {
        case DailyChallengeType.destroyObjects:
          progress = _dailyObjects;
          break;
        case DailyChallengeType.dealDamage:
          progress = _dailyDamage;
          break;
        case DailyChallengeType.reachCombo:
          progress = _dailyMaxCombo;
          break;
        case DailyChallengeType.reachRage:
          progress = _dailyReachedNuclear ? challenge.target : 0;
          break;
        case DailyChallengeType.playSessions:
          progress = _dailySessions;
          break;
        case DailyChallengeType.playMode:
          progress = _dailyModesPlayed.length;
          break;
      }
      _dailyChallengeProgress[challenge.id] = progress;
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalDestruction', _userProgress.totalDestruction);
    await prefs.setInt('totalObjects', _userProgress.totalObjects);
    await prefs.setInt('totalSessions', _userProgress.totalSessions);
    await prefs.setInt('currentLevel', _userProgress.currentLevel);
    await prefs.setInt('currentXP', _userProgress.currentXP);
    await prefs.setInt('dailyDestruction', _userProgress.dailyDestruction);
    await prefs.setString('lastPlayDate', _userProgress.lastPlayDate.toIso8601String());
    await prefs.setInt('dailyStreak', _userProgress.dailyStreak);
    
    // Save achievements
    await prefs.setStringList('achievements', _userProgress.achievements);
    
    // Save mode high scores
    await prefs.setString('modeHighScores', json.encode(_userProgress.modeHighScores));
    
    // Save modes played
    await prefs.setStringList('modesPlayed', _userProgress.modesPlayed.toList());
    
    // Save daily tracking
    await prefs.setInt('dailySessions', _dailySessions);
    await prefs.setInt('dailyObjects', _dailyObjects);
    await prefs.setInt('dailyDamage', _dailyDamage);
    await prefs.setInt('dailyMaxCombo', _dailyMaxCombo);
    await prefs.setBool('dailyReachedNuclear', _dailyReachedNuclear);
    await prefs.setStringList('completedDailyChallenges', _completedDailyChallenges.toList());
    await prefs.setStringList('dailyModesPlayed', _dailyModesPlayed.toList());
  }

  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all game-related keys
    await prefs.remove('totalDestruction');
    await prefs.remove('totalObjects');
    await prefs.remove('totalSessions');
    await prefs.remove('currentLevel');
    await prefs.remove('currentXP');
    await prefs.remove('dailyDestruction');
    await prefs.remove('lastPlayDate');
    await prefs.remove('dailyStreak');
    await prefs.remove('achievements');
    await prefs.remove('modeHighScores');
    await prefs.remove('modesPlayed');
    await prefs.remove('dailySessions');
    await prefs.remove('dailyObjects');
    await prefs.remove('dailyDamage');
    await prefs.remove('dailyMaxCombo');
    await prefs.remove('dailyReachedNuclear');
    await prefs.remove('completedDailyChallenges');
    await prefs.remove('dailyModesPlayed');
    
    // Reset in-memory state
    _userProgress = UserProgress();
    _dailySessions = 0;
    _dailyObjects = 0;
    _dailyDamage = 0;
    _dailyMaxCombo = 0;
    _dailyReachedNuclear = false;
    _dailyModesPlayed.clear();
    _completedDailyChallenges.clear();
    _dailyChallengeProgress.clear();
    _newlyUnlockedAchievements.clear();
    
    _loadTodaysChallenges();
    notifyListeners();
  }

  void startGame(DestructionMode mode) {
    _currentSession = GameSession(mode: mode, isActive: true);
    _reachedNuclearThisSession = false;
    _previousLevel = _userProgress.currentLevel;
    floatingDamages.clear();
    particles.clear();
    
    // Start background music
    _soundService.startBackgroundMusic(mode.id);
    
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
      
      // Stop music
      _soundService.stopBackgroundMusic();
      
      // Play victory sound
      _soundService.playVictory();
      
      // Record session
      _userProgress.recordSession(_currentSession!);
      
      // Track mode played
      _userProgress.modesPlayed.add(_currentSession!.mode.id);
      _dailyModesPlayed.add(_currentSession!.mode.id);
      
      // Update daily tracking
      _dailySessions++;
      _dailyObjects += _currentSession!.objectsDestroyed;
      _dailyDamage += _currentSession!.totalDamage;
      if (_currentSession!.maxCombo > _dailyMaxCombo) {
        _dailyMaxCombo = _currentSession!.maxCombo;
      }
      if (_reachedNuclearThisSession) {
        _dailyReachedNuclear = true;
      }
      
      // Update daily challenge progress
      _updateChallengeProgress();
      _checkDailyChallenges();
      
      // Check achievements
      _checkAchievements(_currentSession!);
      
      // Check for level up
      if (_userProgress.currentLevel > _previousLevel) {
        _soundService.playLevelUp();
      }
      
      _saveProgress();
    }
    _gameTimer?.cancel();
    _comboTimer?.cancel();
    notifyListeners();
  }

  void _checkDailyChallenges() {
    for (final challenge in _todaysChallenges) {
      if (_completedDailyChallenges.contains(challenge.id)) continue;
      
      final progress = _dailyChallengeProgress[challenge.id] ?? 0;
      if (progress >= challenge.target) {
        _completedDailyChallenges.add(challenge.id);
        _userProgress.addXP(challenge.xpReward);
        _soundService.playAchievement();
      }
    }
  }

  void _checkAchievements(GameSession session) {
    _newlyUnlockedAchievements.clear();
    
    for (final achievement in Achievements.all) {
      if (_userProgress.achievements.contains(achievement.id)) continue;
      
      bool unlocked = false;
      
      switch (achievement.type) {
        case AchievementType.sessionsPlayed:
          unlocked = _userProgress.totalSessions >= achievement.requirement;
          break;
        case AchievementType.objectsDestroyed:
          unlocked = _userProgress.totalObjects >= achievement.requirement;
          break;
        case AchievementType.totalDestruction:
          unlocked = _userProgress.totalDestruction >= achievement.requirement;
          break;
        case AchievementType.singleSession:
          unlocked = session.totalDamage >= achievement.requirement;
          break;
        case AchievementType.maxCombo:
          unlocked = session.maxCombo >= achievement.requirement;
          break;
        case AchievementType.rageLevel:
          unlocked = _reachedNuclearThisSession;
          break;
        case AchievementType.modeComplete:
          unlocked = _userProgress.modesPlayed.length >= achievement.requirement;
          break;
        case AchievementType.streak:
          unlocked = _userProgress.dailyStreak >= achievement.requirement;
          break;
        case AchievementType.special:
          if (achievement.id == 'speed_demon') {
            unlocked = session.objectsDestroyed >= 100 && 
                       session.duration.inSeconds <= 60;
          }
          break;
      }
      
      if (unlocked) {
        _userProgress.achievements.add(achievement.id);
        _userProgress.addXP(achievement.xpReward);
        _newlyUnlockedAchievements.add(achievement);
        _soundService.playAchievement();
      }
    }
  }

  void processShake(double x, double y, double z) {
    if (_currentSession == null || !_currentSession!.isActive) return;

    final magnitude = sqrt(x * x + y * y + z * z);
    final normalizedMagnitude = ((magnitude - 9.8).abs() / 30).clamp(0.0, 1.0);
    
    _currentShakeIntensity = normalizedMagnitude;
    _isShaking = normalizedMagnitude > 0.1;
    
    _currentSession!.updateRage(normalizedMagnitude);
    final newRageLevel = RageColors.getLevel(_currentSession!.rageLevel);
    
    // Check if reached nuclear
    if (newRageLevel == RageLevel.nuclear && !_reachedNuclearThisSession) {
      _reachedNuclearThisSession = true;
      _soundService.playNuclear();
    }

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
    
    // Play sound based on combo milestones
    if (_currentSession!.currentCombo > 0 && _currentSession!.currentCombo % 10 == 0) {
      _soundService.playCombo();
    } else {
      _soundService.playDestroy();
    }
    
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
    // Check if haptics are enabled in settings
    if (!_soundService.hapticsEnabled) return;
    
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
    
    // Play tap sound
    _soundService.playTap();
    
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

  // Get challenge progress for UI
  double getChallengeProgress(DailyChallenge challenge) {
    final progress = _dailyChallengeProgress[challenge.id] ?? 0;
    return (progress / challenge.target).clamp(0.0, 1.0);
  }

  String getChallengeProgressText(DailyChallenge challenge) {
    final progress = _dailyChallengeProgress[challenge.id] ?? 0;
    if (challenge.type == DailyChallengeType.dealDamage) {
      return '${_formatNumber(progress)}/${_formatNumber(challenge.target)}';
    }
    return '$progress/${challenge.target}';
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$$value';
  }

  bool isChallengeCompleted(DailyChallenge challenge) {
    return _completedDailyChallenges.contains(challenge.id);
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
