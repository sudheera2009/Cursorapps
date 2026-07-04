import 'aura_reading.dart';

/// Persistent player state for AURA METER.
class UserProfile {
  int auraPoints; // spendable currency
  int totalScans;
  int bestScore;
  int duelsWon;
  int duelsPlayed;
  int dailyStreak;
  DateTime lastScanDate;

  Set<String> discoveredAuras; // aura type ids seen at least once
  Set<String> unlockedFrames;
  String currentFrame;
  List<String> unlockedAchievements;
  List<AuraReading> history;

  UserProfile({
    this.auraPoints = 0,
    this.totalScans = 0,
    this.bestScore = 0,
    this.duelsWon = 0,
    this.duelsPlayed = 0,
    this.dailyStreak = 0,
    DateTime? lastScanDate,
    Set<String>? discoveredAuras,
    Set<String>? unlockedFrames,
    this.currentFrame = 'default',
    List<String>? unlockedAchievements,
    List<AuraReading>? history,
  })  : lastScanDate = lastScanDate ?? DateTime.fromMillisecondsSinceEpoch(0),
        discoveredAuras = discoveredAuras ?? <String>{},
        unlockedFrames = unlockedFrames ?? {'default'},
        unlockedAchievements = unlockedAchievements ?? <String>[],
        history = history ?? <AuraReading>[];

  int get level => (totalScans ~/ 5) + 1;

  double get levelProgress => (totalScans % 5) / 5.0;

  int get winRate =>
      duelsPlayed == 0 ? 0 : ((duelsWon / duelsPlayed) * 100).round();

  bool unlockFrame(String id, int cost) {
    if (unlockedFrames.contains(id)) return true;
    if (auraPoints < cost) return false;
    auraPoints -= cost;
    unlockedFrames.add(id);
    return true;
  }
}
