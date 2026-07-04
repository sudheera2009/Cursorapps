enum ChallengeType { scanCount, reachScore, winDuel, discoverNew }

class DailyChallenge {
  final String id;
  final String title;
  final String emoji;
  final ChallengeType type;
  final int target;
  final int auraReward;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.emoji,
    required this.type,
    required this.target,
    required this.auraReward,
  });
}

class DailyChallenges {
  static const List<DailyChallenge> _pool = [
    DailyChallenge(
      id: 'scan_3',
      title: 'Scan your aura 3 times',
      emoji: '🔍',
      type: ChallengeType.scanCount,
      target: 3,
      auraReward: 100,
    ),
    DailyChallenge(
      id: 'scan_5',
      title: 'Scan your aura 5 times',
      emoji: '📡',
      type: ChallengeType.scanCount,
      target: 5,
      auraReward: 200,
    ),
    DailyChallenge(
      id: 'score_6000',
      title: 'Hit a 6000+ aura score',
      emoji: '✨',
      type: ChallengeType.reachScore,
      target: 6000,
      auraReward: 150,
    ),
    DailyChallenge(
      id: 'score_8000',
      title: 'Hit an 8000+ aura score',
      emoji: '🌟',
      type: ChallengeType.reachScore,
      target: 8000,
      auraReward: 300,
    ),
    DailyChallenge(
      id: 'duel_win',
      title: 'Win an aura duel',
      emoji: '⚔️',
      type: ChallengeType.winDuel,
      target: 1,
      auraReward: 150,
    ),
    DailyChallenge(
      id: 'discover',
      title: 'Discover a new aura type',
      emoji: '🌈',
      type: ChallengeType.discoverNew,
      target: 1,
      auraReward: 250,
    ),
  ];

  /// Deterministically pick 3 challenges for the given day.
  static List<DailyChallenge> forDay(DateTime day) {
    final seed = day.year * 10000 + day.month * 100 + day.day;
    final indices = <int>{};
    var s = seed;
    while (indices.length < 3) {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      indices.add(s % _pool.length);
    }
    return indices.map((i) => _pool[i]).toList();
  }
}
