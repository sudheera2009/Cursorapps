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
  })  : modeHighScores = modeHighScores ?? {},
        achievements = achievements ?? [],
        lastPlayDate = lastPlayDate ?? DateTime.now(),
        modesPlayed = modesPlayed ?? {};

  int get xpForNextLevel => currentLevel * 1000;

  double get levelProgress => currentXP / xpForNextLevel;

  void addXP(int xp) {
    currentXP += xp;
    while (currentXP >= xpForNextLevel) {
      currentXP -= xpForNextLevel;
      currentLevel++;
    }
  }

  void recordSession(GameSession session) {
    totalDestruction += session.totalDamage;
    totalObjects += session.objectsDestroyed;
    totalSessions++;
    dailyDestruction += session.totalDamage;

    final currentHighScore = modeHighScores[session.mode.id] ?? 0;
    if (session.totalDamage > currentHighScore) {
      modeHighScores[session.mode.id] = session.totalDamage;
    }

    addXP(session.totalDamage ~/ 100);
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
