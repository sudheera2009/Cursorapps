import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement.dart';
import '../models/aura_frame.dart';
import '../models/aura_reading.dart';
import '../models/aura_type.dart';
import '../models/daily_challenge.dart';
import '../models/user_profile.dart';
import '../services/feedback_service.dart';

class AuraProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  final Random _random = Random();
  final FeedbackService _feedback = FeedbackService();

  AuraReading? _lastReading;
  final List<Achievement> _newlyUnlocked = [];

  // Daily tracking (reset each calendar day).
  int _dailyScans = 0;
  int _dailyBestScore = 0;
  int _dailyDuelWins = 0;
  int _dailyDiscoveries = 0;
  Set<String> _completedChallenges = {};
  List<DailyChallenge> _todaysChallenges = [];

  UserProfile get profile => _profile;
  AuraReading? get lastReading => _lastReading;
  List<Achievement> get newlyUnlocked => _newlyUnlocked;
  List<DailyChallenge> get todaysChallenges => _todaysChallenges;

  AuraProvider() {
    _load();
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    _profile = UserProfile(
      auraPoints: prefs.getInt('auraPoints') ?? 0,
      totalScans: prefs.getInt('totalScans') ?? 0,
      bestScore: prefs.getInt('bestScore') ?? 0,
      duelsWon: prefs.getInt('duelsWon') ?? 0,
      duelsPlayed: prefs.getInt('duelsPlayed') ?? 0,
      dailyStreak: prefs.getInt('dailyStreak') ?? 0,
      lastScanDate: DateTime.tryParse(prefs.getString('lastScanDate') ?? ''),
      discoveredAuras: (prefs.getStringList('discoveredAuras') ?? []).toSet(),
      unlockedFrames:
          (prefs.getStringList('unlockedFrames') ?? ['default']).toSet(),
      currentFrame: prefs.getString('currentFrame') ?? 'default',
      unlockedAchievements: prefs.getStringList('unlockedAchievements') ?? [],
    );

    final historyJson = prefs.getString('history');
    if (historyJson != null) {
      final List<dynamic> decoded = json.decode(historyJson);
      _profile.history =
          decoded.map((e) => AuraReading.fromJson(e)).toList();
    }

    _checkDailyReset(prefs);
    _todaysChallenges = DailyChallenges.forDay(DateTime.now());
    notifyListeners();
  }

  void _checkDailyReset(SharedPreferences prefs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final storedDay =
        DateTime.tryParse(prefs.getString('dailyStatsDate') ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
    final storedDayOnly =
        DateTime(storedDay.year, storedDay.month, storedDay.day);

    if (today.isAfter(storedDayOnly)) {
      _dailyScans = 0;
      _dailyBestScore = 0;
      _dailyDuelWins = 0;
      _dailyDiscoveries = 0;
      _completedChallenges = {};
      prefs.setString('dailyStatsDate', now.toIso8601String());
      prefs.setInt('dailyScans', 0);
      prefs.setInt('dailyBestScore', 0);
      prefs.setInt('dailyDuelWins', 0);
      prefs.setInt('dailyDiscoveries', 0);
      prefs.setStringList('completedChallenges', []);
    } else {
      _dailyScans = prefs.getInt('dailyScans') ?? 0;
      _dailyBestScore = prefs.getInt('dailyBestScore') ?? 0;
      _dailyDuelWins = prefs.getInt('dailyDuelWins') ?? 0;
      _dailyDiscoveries = prefs.getInt('dailyDiscoveries') ?? 0;
      _completedChallenges =
          (prefs.getStringList('completedChallenges') ?? []).toSet();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auraPoints', _profile.auraPoints);
    await prefs.setInt('totalScans', _profile.totalScans);
    await prefs.setInt('bestScore', _profile.bestScore);
    await prefs.setInt('duelsWon', _profile.duelsWon);
    await prefs.setInt('duelsPlayed', _profile.duelsPlayed);
    await prefs.setInt('dailyStreak', _profile.dailyStreak);
    await prefs.setString('lastScanDate', _profile.lastScanDate.toIso8601String());
    await prefs.setStringList(
        'discoveredAuras', _profile.discoveredAuras.toList());
    await prefs.setStringList('unlockedFrames', _profile.unlockedFrames.toList());
    await prefs.setString('currentFrame', _profile.currentFrame);
    await prefs.setStringList(
        'unlockedAchievements', _profile.unlockedAchievements);
    final historyJson =
        _profile.history.take(100).map((r) => r.toJson()).toList();
    await prefs.setString('history', json.encode(historyJson));

    await prefs.setInt('dailyScans', _dailyScans);
    await prefs.setInt('dailyBestScore', _dailyBestScore);
    await prefs.setInt('dailyDuelWins', _dailyDuelWins);
    await prefs.setInt('dailyDiscoveries', _dailyDiscoveries);
    await prefs.setStringList('completedChallenges', _completedChallenges.toList());
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _profile = UserProfile();
    _lastReading = null;
    _dailyScans = 0;
    _dailyBestScore = 0;
    _dailyDuelWins = 0;
    _dailyDiscoveries = 0;
    _completedChallenges = {};
    _todaysChallenges = DailyChallenges.forDay(DateTime.now());
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Core scan logic
  // ---------------------------------------------------------------------------

  /// The daily aura is deterministic per calendar day so it feels like a real
  /// "reading of the day" that friends can compare.
  AuraType get dailyAura {
    final now = DateTime.now();
    final seed = now.year * 366 + now.month * 31 + now.day;
    return AuraTypes.all[seed % AuraTypes.all.length];
  }

  AuraType _rollAuraType() {
    // Weighted by rarity: commons frequent, mythic extremely rare.
    final weighted = <AuraType>[];
    for (final type in AuraTypes.all) {
      int weight;
      switch (type.rarity) {
        case AuraRarity.common:
          weight = 40;
          break;
        case AuraRarity.rare:
          weight = 22;
          break;
        case AuraRarity.epic:
          weight = 10;
          break;
        case AuraRarity.legendary:
          weight = 4;
          break;
        case AuraRarity.mythic:
          weight = 1;
          break;
      }
      for (int i = 0; i < weight; i++) {
        weighted.add(type);
      }
    }
    return weighted[_random.nextInt(weighted.length)];
  }

  /// Generates a fresh reading. Rarer auras skew toward higher scores.
  AuraReading generateReading() {
    final type = _rollAuraType();

    int base;
    switch (type.rarity) {
      case AuraRarity.common:
        base = 1500 + _random.nextInt(4500);
        break;
      case AuraRarity.rare:
        base = 3500 + _random.nextInt(4500);
        break;
      case AuraRarity.epic:
        base = 5000 + _random.nextInt(4000);
        break;
      case AuraRarity.legendary:
        base = 7000 + _random.nextInt(2999);
        break;
      case AuraRarity.mythic:
        base = 9000 + _random.nextInt(1000);
        break;
    }

    return AuraReading(
      typeId: type.id,
      score: base.clamp(0, 9999),
      timestamp: DateTime.now(),
      charisma: 20 + _random.nextInt(81),
      chaos: 20 + _random.nextInt(81),
      luck: 20 + _random.nextInt(81),
      mystery: 20 + _random.nextInt(81),
    );
  }

  /// Records a completed scan and returns the newly unlocked achievements.
  void commitReading(AuraReading reading) {
    _lastReading = reading;
    _profile.totalScans++;
    _profile.history.insert(0, reading);
    if (reading.score > _profile.bestScore) {
      _profile.bestScore = reading.score;
    }

    final wasNew = !_profile.discoveredAuras.contains(reading.typeId);
    _profile.discoveredAuras.add(reading.typeId);

    // Aura points earned scale with the score.
    final earned = 20 + (reading.score ~/ 100);
    _profile.auraPoints += earned;

    _updateStreak();

    _dailyScans++;
    if (reading.score > _dailyBestScore) _dailyBestScore = reading.score;
    if (wasNew) _dailyDiscoveries++;

    _checkChallenges();
    _checkAchievements();
    _feedback.reveal();
    _save();
    notifyListeners();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = _profile.lastScanDate;
    final lastDay = DateTime(last.year, last.month, last.day);
    final diff = today.difference(lastDay).inDays;
    if (diff == 1) {
      _profile.dailyStreak++;
    } else if (diff > 1) {
      _profile.dailyStreak = 1;
    } else if (_profile.dailyStreak == 0) {
      _profile.dailyStreak = 1;
    }
    _profile.lastScanDate = now;
  }

  // ---------------------------------------------------------------------------
  // Duels
  // ---------------------------------------------------------------------------

  /// Simulates an opponent for an aura duel. Returns the opponent's reading.
  AuraReading generateOpponent({String? name}) {
    final type = _rollAuraType();
    final base = 1500 + _random.nextInt(8000);
    return AuraReading(
      typeId: type.id,
      score: base.clamp(0, 9999),
      timestamp: DateTime.now(),
      charisma: 20 + _random.nextInt(81),
      chaos: 20 + _random.nextInt(81),
      luck: 20 + _random.nextInt(81),
      mystery: 20 + _random.nextInt(81),
    );
  }

  /// Records a duel result. [won] true if the player won.
  void recordDuel(bool won) {
    _profile.duelsPlayed++;
    if (won) {
      _profile.duelsWon++;
      _dailyDuelWins++;
      _profile.auraPoints += 100;
    }
    _checkChallenges();
    _checkAchievements();
    _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Frames / shop
  // ---------------------------------------------------------------------------
  bool purchaseFrame(AuraFrame frame) {
    final ok = _profile.unlockFrame(frame.id, frame.cost);
    if (ok) {
      _profile.currentFrame = frame.id;
      _save();
      notifyListeners();
    }
    return ok;
  }

  void selectFrame(String id) {
    if (_profile.unlockedFrames.contains(id)) {
      _profile.currentFrame = id;
      _save();
      notifyListeners();
    }
  }

  void addAuraPoints(int amount) {
    if (amount <= 0) return;
    _profile.auraPoints += amount;
    _checkAchievements();
    _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Challenges & achievements
  // ---------------------------------------------------------------------------
  int challengeProgress(DailyChallenge c) {
    switch (c.type) {
      case ChallengeType.scanCount:
        return _dailyScans;
      case ChallengeType.reachScore:
        return _dailyBestScore >= c.target ? c.target : _dailyBestScore;
      case ChallengeType.winDuel:
        return _dailyDuelWins;
      case ChallengeType.discoverNew:
        return _dailyDiscoveries;
    }
  }

  bool isChallengeComplete(DailyChallenge c) =>
      _completedChallenges.contains(c.id);

  void _checkChallenges() {
    for (final c in _todaysChallenges) {
      if (_completedChallenges.contains(c.id)) continue;
      if (challengeProgress(c) >= c.target) {
        _completedChallenges.add(c.id);
        _profile.auraPoints += c.auraReward;
      }
    }
  }

  void clearNewlyUnlocked() => _newlyUnlocked.clear();

  void _checkAchievements() {
    _newlyUnlocked.clear();
    for (final a in Achievements.all) {
      if (_profile.unlockedAchievements.contains(a.id)) continue;
      bool unlocked = false;
      switch (a.type) {
        case AchievementType.totalScans:
          unlocked = _profile.totalScans >= a.requirement;
          break;
        case AchievementType.highScore:
          unlocked = _profile.bestScore >= a.requirement;
          break;
        case AchievementType.legendaryUnlock:
          unlocked = _profile.discoveredAuras.any((id) =>
              AuraTypes.byId(id).rarity == AuraRarity.legendary);
          break;
        case AchievementType.mythicUnlock:
          unlocked = _profile.discoveredAuras
              .any((id) => AuraTypes.byId(id).rarity == AuraRarity.mythic);
          break;
        case AchievementType.collectAuras:
          unlocked = _profile.discoveredAuras.length >= a.requirement;
          break;
        case AchievementType.streak:
          unlocked = _profile.dailyStreak >= a.requirement;
          break;
        case AchievementType.duelsWon:
          unlocked = _profile.duelsWon >= a.requirement;
          break;
        case AchievementType.auraPoints:
          unlocked = _profile.auraPoints >= a.requirement;
          break;
      }
      if (unlocked) {
        _profile.unlockedAchievements.add(a.id);
        _profile.auraPoints += a.auraReward;
        _newlyUnlocked.add(a);
      }
    }
  }
}
