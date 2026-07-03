import 'package:flutter/material.dart';

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DailyChallengeType type;
  final int target;
  final int xpReward;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.target,
    required this.xpReward,
  });
}

enum DailyChallengeType {
  destroyObjects,
  dealDamage,
  reachCombo,
  reachRage,
  playSessions,
  playMode,
  playDuration,
  earnCoins,
}

class DailyChallenges {
  static List<DailyChallenge> get allChallenges => [
    const DailyChallenge(
      id: 'destroy_50',
      title: 'Object Smasher',
      description: 'Destroy 50 objects',
      icon: Icons.broken_image,
      color: Color(0xFF2196F3),
      type: DailyChallengeType.destroyObjects,
      target: 50,
      xpReward: 100,
    ),
    const DailyChallenge(
      id: 'destroy_100',
      title: 'Demolition Derby',
      description: 'Destroy 100 objects',
      icon: Icons.blur_circular,
      color: Color(0xFF00BCD4),
      type: DailyChallengeType.destroyObjects,
      target: 100,
      xpReward: 200,
    ),
    const DailyChallenge(
      id: 'destroy_200',
      title: 'Wrecking Ball',
      description: 'Destroy 200 objects',
      icon: Icons.lens_blur,
      color: Color(0xFF9C27B0),
      type: DailyChallengeType.destroyObjects,
      target: 200,
      xpReward: 350,
    ),
    const DailyChallenge(
      id: 'damage_500k',
      title: 'Half Million Hit',
      description: 'Deal \$500,000 damage',
      icon: Icons.attach_money,
      color: Color(0xFF4CAF50),
      type: DailyChallengeType.dealDamage,
      target: 500000,
      xpReward: 150,
    ),
    const DailyChallenge(
      id: 'damage_1m',
      title: 'Million Dollar Day',
      description: 'Deal \$1,000,000 damage',
      icon: Icons.monetization_on,
      color: Color(0xFFFFD700),
      type: DailyChallengeType.dealDamage,
      target: 1000000,
      xpReward: 250,
    ),
    const DailyChallenge(
      id: 'damage_5m',
      title: 'Five Star Fury',
      description: 'Deal \$5,000,000 damage',
      icon: Icons.stars,
      color: Color(0xFFFF9800),
      type: DailyChallengeType.dealDamage,
      target: 5000000,
      xpReward: 400,
    ),
    const DailyChallenge(
      id: 'combo_25',
      title: 'Combo Starter',
      description: 'Reach a 25x combo',
      icon: Icons.bolt,
      color: Color(0xFFFFEB3B),
      type: DailyChallengeType.reachCombo,
      target: 25,
      xpReward: 150,
    ),
    const DailyChallenge(
      id: 'combo_50',
      title: 'Combo Champion',
      description: 'Reach a 50x combo',
      icon: Icons.flash_on,
      color: Color(0xFFFF5722),
      type: DailyChallengeType.reachCombo,
      target: 50,
      xpReward: 300,
    ),
    const DailyChallenge(
      id: 'rage_nuclear',
      title: 'Nuclear Option',
      description: 'Reach NUCLEAR rage',
      icon: Icons.whatshot,
      color: Color(0xFFF44336),
      type: DailyChallengeType.reachRage,
      target: 5,
      xpReward: 200,
    ),
    const DailyChallenge(
      id: 'play_3',
      title: 'Triple Threat',
      description: 'Play 3 sessions',
      icon: Icons.play_circle,
      color: Color(0xFF673AB7),
      type: DailyChallengeType.playSessions,
      target: 3,
      xpReward: 100,
    ),
    const DailyChallenge(
      id: 'play_5',
      title: 'Rage Runner',
      description: 'Play 5 sessions',
      icon: Icons.repeat,
      color: Color(0xFF3F51B5),
      type: DailyChallengeType.playSessions,
      target: 5,
      xpReward: 175,
    ),
    const DailyChallenge(
      id: 'play_10',
      title: 'Destruction Devotee',
      description: 'Play 10 sessions',
      icon: Icons.all_inclusive,
      color: Color(0xFFE91E63),
      type: DailyChallengeType.playSessions,
      target: 10,
      xpReward: 300,
    ),
    // New challenge types
    const DailyChallenge(
      id: 'play_5_mins',
      title: 'Five Minute Fury',
      description: 'Play for 5 minutes total',
      icon: Icons.timer,
      color: Color(0xFF00ACC1),
      type: DailyChallengeType.playDuration,
      target: 300,
      xpReward: 125,
    ),
    const DailyChallenge(
      id: 'play_10_mins',
      title: 'Ten Minute Terror',
      description: 'Play for 10 minutes total',
      icon: Icons.hourglass_bottom,
      color: Color(0xFF7B1FA2),
      type: DailyChallengeType.playDuration,
      target: 600,
      xpReward: 200,
    ),
    const DailyChallenge(
      id: 'earn_100_coins',
      title: 'Coin Collector',
      description: 'Earn 100 Rage Coins',
      icon: Icons.paid,
      color: Color(0xFFFFD700),
      type: DailyChallengeType.earnCoins,
      target: 100,
      xpReward: 150,
    ),
    const DailyChallenge(
      id: 'earn_250_coins',
      title: 'Coin Hunter',
      description: 'Earn 250 Rage Coins',
      icon: Icons.savings,
      color: Color(0xFFFFA000),
      type: DailyChallengeType.earnCoins,
      target: 250,
      xpReward: 275,
    ),
    const DailyChallenge(
      id: 'combo_75',
      title: 'Combo Crusher',
      description: 'Reach a 75x combo',
      icon: Icons.electric_bolt,
      color: Color(0xFFE65100),
      type: DailyChallengeType.reachCombo,
      target: 75,
      xpReward: 250,
    ),
    const DailyChallenge(
      id: 'damage_10m',
      title: 'Ten Million Titan',
      description: 'Deal \$10,000,000 damage',
      icon: Icons.diamond,
      color: Color(0xFF00E5FF),
      type: DailyChallengeType.dealDamage,
      target: 10000000,
      xpReward: 500,
    ),
    const DailyChallenge(
      id: 'destroy_300',
      title: 'Destruction Dominator',
      description: 'Destroy 300 objects',
      icon: Icons.grain,
      color: Color(0xFFFF1744),
      type: DailyChallengeType.destroyObjects,
      target: 300,
      xpReward: 450,
    ),
  ];

  static List<DailyChallenge> getDailyChallenges(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final shuffled = List<DailyChallenge>.from(allChallenges);
    _shuffleWithSeed(shuffled, seed);
    return shuffled.take(3).toList();
  }

  static void _shuffleWithSeed<T>(List<T> list, int seed) {
    var currentSeed = seed;
    for (var i = list.length - 1; i > 0; i--) {
      currentSeed = (currentSeed * 1103515245 + 12345) & 0x7fffffff;
      final j = currentSeed % (i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }
}
