import 'package:flutter/material.dart';

/// Cosmetic frames applied to the shareable aura card, purchasable with
/// aura points earned in-app.
class AuraFrame {
  final String id;
  final String name;
  final String emoji;
  final int cost;
  final List<Color> colors;

  const AuraFrame({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.colors,
  });
}

class AuraFrames {
  static const List<AuraFrame> all = [
    AuraFrame(
      id: 'default',
      name: 'Classic',
      emoji: '⚪',
      cost: 0,
      colors: [Color(0xFF2A2551), Color(0xFF15122A)],
    ),
    AuraFrame(
      id: 'neon',
      name: 'Neon Grid',
      emoji: '🟣',
      cost: 500,
      colors: [Color(0xFF9D5CFF), Color(0xFF00E5FF)],
    ),
    AuraFrame(
      id: 'sunset',
      name: 'Sunset Fade',
      emoji: '🟠',
      cost: 800,
      colors: [Color(0xFFFF9E1B), Color(0xFFFF4FD8)],
    ),
    AuraFrame(
      id: 'matrix',
      name: 'Matrix',
      emoji: '🟢',
      cost: 1200,
      colors: [Color(0xFF4AE38C), Color(0xFF0E8F58)],
    ),
    AuraFrame(
      id: 'galaxy',
      name: 'Galaxy',
      emoji: '🌌',
      cost: 2000,
      colors: [Color(0xFF5B2BD6), Color(0xFFFF4FD8)],
    ),
    AuraFrame(
      id: 'gold',
      name: 'Solid Gold',
      emoji: '👑',
      cost: 5000,
      colors: [Color(0xFFFFD54A), Color(0xFFFF9E1B)],
    ),
  ];

  static AuraFrame byId(String id) =>
      all.firstWhere((f) => f.id == id, orElse: () => all.first);
}
