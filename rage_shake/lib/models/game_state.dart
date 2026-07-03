import 'package:flutter/material.dart';
import 'destruction_mode.dart';

class GameSession {
  final DestructionMode mode;
  int totalDamage;
  int objectsDestroyed;
  int maxCombo;
  int currentCombo;
  double rageLevel;
  Duration duration;
  DateTime startTime;
  bool isActive;

  GameSession({
    required this.mode,
    this.totalDamage = 0,
    this.objectsDestroyed = 0,
    this.maxCombo = 0,
    this.currentCombo = 0,
    this.rageLevel = 0.0,
    this.duration = Duration.zero,
    DateTime? startTime,
    this.isActive = false,
  }) : startTime = startTime ?? DateTime.now();

  void addDamage(int damage) {
    totalDamage += damage * (1 + currentCombo ~/ 10);
    objectsDestroyed++;
    currentCombo++;
    if (currentCombo > maxCombo) {
      maxCombo = currentCombo;
    }
  }

  void resetCombo() {
    currentCombo = 0;
  }

  void updateRage(double shake) {
    rageLevel = (rageLevel + shake * 0.1).clamp(0.0, 1.0);
    if (shake < 0.1) {
      rageLevel = (rageLevel - 0.02).clamp(0.0, 1.0);
    }
  }

  String get formattedDamage {
    if (totalDamage >= 1000000000) {
      return '\$${(totalDamage / 1000000000).toStringAsFixed(1)}B';
    } else if (totalDamage >= 1000000) {
      return '\$${(totalDamage / 1000000).toStringAsFixed(1)}M';
    } else if (totalDamage >= 1000) {
      return '\$${(totalDamage / 1000).toStringAsFixed(1)}K';
    }
    return '\$$totalDamage';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Session record for history tracking
class SessionRecord {
  final int damage;
  final int objects;
  final int maxCombo;
  final String modeId;
  final String peakRage;
  final int durationSeconds;
  final DateTime playedAt;

  SessionRecord({
    required this.damage,
    required this.objects,
    required this.maxCombo,
    required this.modeId,
    required this.peakRage,
    required this.durationSeconds,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
    'damage': damage,
    'objects': objects,
    'maxCombo': maxCombo,
    'modeId': modeId,
    'peakRage': peakRage,
    'durationSeconds': durationSeconds,
    'playedAt': playedAt.toIso8601String(),
  };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
    damage: json['damage'] ?? 0,
    objects: json['objects'] ?? 0,
    maxCombo: json['maxCombo'] ?? 0,
    modeId: json['modeId'] ?? 'office',
    peakRage: json['peakRage'] ?? 'calm',
    durationSeconds: json['durationSeconds'] ?? 0,
    playedAt: DateTime.tryParse(json['playedAt'] ?? '') ?? DateTime.now(),
  );
}

class UserProgress {
  int totalDestruction;
  int totalObjects;
  int totalSessions;
  int currentLevel;
  int currentXP;
  Map<String, int> modeHighScores;
  List<String> achievements;
  int dailyDestruction;
  int dailyGoal;
  DateTime lastPlayDate;
  int dailyStreak;
  Set<String> modesPlayed;
  
  // Statistics tracking
  List<SessionRecord> sessionHistory;
  Map<String, int> modePlayCounts;
  Map<String, int> rageLevelCounts;
  int bestSessionDamage;
  int highestCombo;
  int mostObjectsSession;
  int longestSession; // in seconds
  
  // Rage Coins (premium currency)
  int rageCoins;
  Set<String> unlockedThemes;
  String currentTheme;

  UserProgress({
    this.totalDestruction = 0,
    this.totalObjects = 0,
    this.totalSessions = 0,
    this.currentLevel = 1,
    this.currentXP = 0,
    Map<String, int>? modeHighScores,
    List<String>? achievements,
    this.dailyDestruction = 0,
    this.dailyGoal = 1000000,
    DateTime? lastPlayDate,
    this.dailyStreak = 0,
    Set<String>? modesPlayed,
    List<SessionRecord>? sessionHistory,
    Map<String, int>? modePlayCounts,
    Map<String, int>? rageLevelCounts,
    this.bestSessionDamage = 0,
    this.highestCombo = 0,
    this.mostObjectsSession = 0,
    this.longestSession = 0,
    this.rageCoins = 0,
    Set<String>? unlockedThemes,
    this.currentTheme = 'default',
  })  : modeHighScores = modeHighScores ?? {},
        achievements = achievements ?? [],
        lastPlayDate = lastPlayDate ?? DateTime.now(),
        modesPlayed = modesPlayed ?? {},
        sessionHistory = sessionHistory ?? [],
        modePlayCounts = modePlayCounts ?? {},
        rageLevelCounts = rageLevelCounts ?? {},
        unlockedThemes = unlockedThemes ?? {'default'};

  int get xpForNextLevel => currentLevel * 1000;

  double get levelProgress => currentXP / xpForNextLevel;

  void addXP(int xp) {
    currentXP += xp;
    while (currentXP >= xpForNextLevel) {
      currentXP -= xpForNextLevel;
      currentLevel++;
    }
  }

  void recordSession(GameSession session, {String peakRageLevel = 'calm'}) {
    totalDestruction += session.totalDamage;
    totalObjects += session.objectsDestroyed;
    totalSessions++;
    dailyDestruction += session.totalDamage;

    final currentHighScore = modeHighScores[session.mode.id] ?? 0;
    if (session.totalDamage > currentHighScore) {
      modeHighScores[session.mode.id] = session.totalDamage;
    }

    // Track personal records
    if (session.totalDamage > bestSessionDamage) {
      bestSessionDamage = session.totalDamage;
    }
    if (session.maxCombo > highestCombo) {
      highestCombo = session.maxCombo;
    }
    if (session.objectsDestroyed > mostObjectsSession) {
      mostObjectsSession = session.objectsDestroyed;
    }
    final sessionSecs = session.duration.inSeconds;
    if (sessionSecs > longestSession) {
      longestSession = sessionSecs;
    }

    // Track mode play count
    modePlayCounts[session.mode.id] = (modePlayCounts[session.mode.id] ?? 0) + 1;

    // Track rage level distribution
    rageLevelCounts[peakRageLevel] = (rageLevelCounts[peakRageLevel] ?? 0) + 1;

    // Add to session history (keep last 100)
    sessionHistory.insert(0, SessionRecord(
      damage: session.totalDamage,
      objects: session.objectsDestroyed,
      maxCombo: session.maxCombo,
      modeId: session.mode.id,
      peakRage: peakRageLevel,
      durationSeconds: sessionSecs,
      playedAt: DateTime.now(),
    ));
    if (sessionHistory.length > 100) {
      sessionHistory.removeLast();
    }

    // Award rage coins based on performance
    final coinsEarned = _calculateCoinsEarned(session);
    rageCoins += coinsEarned;

    addXP(session.totalDamage ~/ 100);
  }

  int _calculateCoinsEarned(GameSession session) {
    int coins = session.totalDamage ~/ 10000; // Base: 1 coin per $10K
    coins += session.maxCombo ~/ 5; // Bonus for combos
    if (session.objectsDestroyed >= 50) coins += 5; // Destruction bonus
    return coins;
  }

  void addRageCoins(int amount) {
    rageCoins += amount;
  }

  bool unlockTheme(String themeId, int cost) {
    if (rageCoins >= cost && !unlockedThemes.contains(themeId)) {
      rageCoins -= cost;
      unlockedThemes.add(themeId);
      return true;
    }
    return false;
  }

  String get formattedTotalDestruction {
    if (totalDestruction >= 1000000000) {
      return '\$${(totalDestruction / 1000000000).toStringAsFixed(1)}B';
    } else if (totalDestruction >= 1000000) {
      return '\$${(totalDestruction / 1000000).toStringAsFixed(1)}M';
    } else if (totalDestruction >= 1000) {
      return '\$${(totalDestruction / 1000).toStringAsFixed(1)}K';
    }
    return '\$$totalDestruction';
  }

  double get dailyProgress => (dailyDestruction / dailyGoal).clamp(0.0, 1.0);

  String get formattedDailyDestruction {
    if (dailyDestruction >= 1000000) {
      return '\$${(dailyDestruction / 1000000).toStringAsFixed(1)}M';
    } else if (dailyDestruction >= 1000) {
      return '\$${(dailyDestruction / 1000).toStringAsFixed(1)}K';
    }
    return '\$$dailyDestruction';
  }
}

class DestroyedObject {
  final Offset position;
  final DestructibleObject object;
  final int damage;
  final DateTime destroyedAt;
  final double scale;

  DestroyedObject({
    required this.position,
    required this.object,
    required this.damage,
    this.scale = 1.0,
  }) : destroyedAt = DateTime.now();
}
