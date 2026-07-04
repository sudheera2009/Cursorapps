import 'package:flutter/material.dart';

enum AuraRarity { common, rare, epic, legendary, mythic }

extension AuraRarityInfo on AuraRarity {
  String get label {
    switch (this) {
      case AuraRarity.common:
        return 'COMMON';
      case AuraRarity.rare:
        return 'RARE';
      case AuraRarity.epic:
        return 'EPIC';
      case AuraRarity.legendary:
        return 'LEGENDARY';
      case AuraRarity.mythic:
        return 'MYTHIC';
    }
  }

  Color get color {
    switch (this) {
      case AuraRarity.common:
        return const Color(0xFF9AA0B5);
      case AuraRarity.rare:
        return const Color(0xFF3EA6FF);
      case AuraRarity.epic:
        return const Color(0xFFB05CFF);
      case AuraRarity.legendary:
        return const Color(0xFFFFB74A);
      case AuraRarity.mythic:
        return const Color(0xFFFF4FD8);
    }
  }
}

/// A distinct aura "personality" the scanner can reveal.
class AuraType {
  final String id;
  final String name;
  final String emoji;
  final String vibe; // short one-liner
  final String description; // longer flavor text
  final List<Color> gradient;
  final AuraRarity rarity;

  const AuraType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.vibe,
    required this.description,
    required this.gradient,
    required this.rarity,
  });

  Color get color => gradient.first;
  Color get glow => gradient.last;
}

class AuraTypes {
  static const List<AuraType> all = [
    AuraType(
      id: 'violet',
      name: 'Mystic Violet',
      emoji: '🔮',
      vibe: 'You radiate main-character energy.',
      description:
          'A rare, magnetic aura. People feel your presence before you even speak. '
          'Intuitive, mysterious, and impossible to ignore.',
      gradient: [Color(0xFF9D5CFF), Color(0xFF5B2BD6)],
      rarity: AuraRarity.epic,
    ),
    AuraType(
      id: 'gold',
      name: 'Golden Radiance',
      emoji: '👑',
      vibe: 'Certified aura farmer. +1000 aura.',
      description:
          'The rarest glow on the spectrum. Confidence, luck, and charisma leak '
          'out of you. Rooms get brighter when you enter.',
      gradient: [Color(0xFFFFD54A), Color(0xFFFF9E1B)],
      rarity: AuraRarity.legendary,
    ),
    AuraType(
      id: 'crimson',
      name: 'Crimson Blaze',
      emoji: '🔥',
      vibe: 'Unhinged in the best way possible.',
      description:
          'Pure passion and fire. You go all in on everything. Bold, loud, and '
          'never boring — a little chaotic, a lot iconic.',
      gradient: [Color(0xFFFF4D4D), Color(0xFFB3001B)],
      rarity: AuraRarity.rare,
    ),
    AuraType(
      id: 'azure',
      name: 'Azure Calm',
      emoji: '🌊',
      vibe: 'Unbothered. Moisturized. Thriving.',
      description:
          'A cool, steady aura that keeps everyone grounded. You are the friend '
          'people call at 3am. Peace radiates off you.',
      gradient: [Color(0xFF3EA6FF), Color(0xFF0057B8)],
      rarity: AuraRarity.common,
    ),
    AuraType(
      id: 'emerald',
      name: 'Emerald Root',
      emoji: '🌿',
      vibe: 'Grounded king/queen energy.',
      description:
          'Balanced, reliable, and quietly powerful. You grow through everything. '
          'Nature-coded and endlessly dependable.',
      gradient: [Color(0xFF4AE38C), Color(0xFF0E8F58)],
      rarity: AuraRarity.common,
    ),
    AuraType(
      id: 'rose',
      name: 'Rose Charm',
      emoji: '💗',
      vibe: 'The rizz is unmatched.',
      description:
          'Sweet, warm, and dangerously charming. People fall for your vibe '
          'instantly. Love follows you around like a puppy.',
      gradient: [Color(0xFFFF7EB6), Color(0xFFD6247A)],
      rarity: AuraRarity.rare,
    ),
    AuraType(
      id: 'cyan',
      name: 'Electric Cyan',
      emoji: '⚡',
      vibe: '100 gecs of pure energy.',
      description:
          'High-voltage aura. You are fast, clever, and always three steps ahead. '
          'Ideas spark off you constantly.',
      gradient: [Color(0xFF00E5FF), Color(0xFF00838F)],
      rarity: AuraRarity.rare,
    ),
    AuraType(
      id: 'obsidian',
      name: 'Obsidian Shadow',
      emoji: '🖤',
      vibe: 'Silent. Deadly. Villain arc loading.',
      description:
          'A deep, cool aura with hidden depths. Mysterious and self-contained. '
          'You keep the world guessing — and you like it that way.',
      gradient: [Color(0xFF6E6A8A), Color(0xFF1B1730)],
      rarity: AuraRarity.epic,
    ),
    AuraType(
      id: 'rainbow',
      name: 'Prismatic Chaos',
      emoji: '🌈',
      vibe: 'Reality bends around you.',
      description:
          'The mythic aura almost nobody unlocks. You contain multitudes — every '
          'color, every mood, every timeline. A walking plot twist.',
      gradient: [Color(0xFFFF4FD8), Color(0xFF00E5FF)],
      rarity: AuraRarity.mythic,
    ),
    AuraType(
      id: 'silver',
      name: 'Silver Ghost',
      emoji: '👻',
      vibe: 'You left them on read. Iconic.',
      description:
          'Cool, elusive, and effortlessly detached. You come and go like a legend. '
          'Low-key but somehow always talked about.',
      gradient: [Color(0xFFC9D2E3), Color(0xFF6B7280)],
      rarity: AuraRarity.common,
    ),
  ];

  static AuraType byId(String id) =>
      all.firstWhere((a) => a.id == id, orElse: () => all.first);
}
