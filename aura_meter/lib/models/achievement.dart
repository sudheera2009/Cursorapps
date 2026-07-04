enum AchievementType {
  totalScans,
  highScore,
  mythicUnlock,
  legendaryUnlock,
  collectAuras,
  streak,
  duelsWon,
  auraPoints,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final AchievementType type;
  final int requirement;
  final int auraReward;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.requirement,
    required this.auraReward,
  });
}

class Achievements {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_scan',
      name: 'First Contact',
      description: 'Complete your first aura scan',
      emoji: '🔍',
      type: AchievementType.totalScans,
      requirement: 1,
      auraReward: 50,
    ),
    Achievement(
      id: 'scan_10',
      name: 'Aura Curious',
      description: 'Scan your aura 10 times',
      emoji: '📡',
      type: AchievementType.totalScans,
      requirement: 10,
      auraReward: 150,
    ),
    Achievement(
      id: 'scan_50',
      name: 'Aura Addict',
      description: 'Scan your aura 50 times',
      emoji: '🛰️',
      type: AchievementType.totalScans,
      requirement: 50,
      auraReward: 500,
    ),
    Achievement(
      id: 'score_8000',
      name: 'Radiant',
      description: 'Score 8000+ on a single scan',
      emoji: '✨',
      type: AchievementType.highScore,
      requirement: 8000,
      auraReward: 300,
    ),
    Achievement(
      id: 'score_9500',
      name: 'Ascended',
      description: 'Score 9500+ on a single scan',
      emoji: '🌟',
      type: AchievementType.highScore,
      requirement: 9500,
      auraReward: 1000,
    ),
    Achievement(
      id: 'legendary',
      name: 'Touched by Gold',
      description: 'Unlock a legendary aura',
      emoji: '👑',
      type: AchievementType.legendaryUnlock,
      requirement: 1,
      auraReward: 500,
    ),
    Achievement(
      id: 'mythic',
      name: 'Reality Bender',
      description: 'Unlock the mythic Prismatic Chaos aura',
      emoji: '🌈',
      type: AchievementType.mythicUnlock,
      requirement: 1,
      auraReward: 2000,
    ),
    Achievement(
      id: 'collector_5',
      name: 'Aura Collector',
      description: 'Discover 5 different aura types',
      emoji: '🗂️',
      type: AchievementType.collectAuras,
      requirement: 5,
      auraReward: 400,
    ),
    Achievement(
      id: 'collector_all',
      name: 'Full Spectrum',
      description: 'Discover all 10 aura types',
      emoji: '🌌',
      type: AchievementType.collectAuras,
      requirement: 10,
      auraReward: 1500,
    ),
    Achievement(
      id: 'streak_3',
      name: 'Consistent Vibes',
      description: 'Reach a 3-day scan streak',
      emoji: '🔥',
      type: AchievementType.streak,
      requirement: 3,
      auraReward: 200,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Weekly Aura Farmer',
      description: 'Reach a 7-day scan streak',
      emoji: '📅',
      type: AchievementType.streak,
      requirement: 7,
      auraReward: 700,
    ),
    Achievement(
      id: 'duel_1',
      name: 'First Blood',
      description: 'Win your first aura duel',
      emoji: '⚔️',
      type: AchievementType.duelsWon,
      requirement: 1,
      auraReward: 100,
    ),
    Achievement(
      id: 'duel_10',
      name: 'Aura Champion',
      description: 'Win 10 aura duels',
      emoji: '🏆',
      type: AchievementType.duelsWon,
      requirement: 10,
      auraReward: 800,
    ),
    Achievement(
      id: 'rich_5000',
      name: 'Aura Banker',
      description: 'Bank 5000 aura points',
      emoji: '💎',
      type: AchievementType.auraPoints,
      requirement: 5000,
      auraReward: 500,
    ),
  ];
}
