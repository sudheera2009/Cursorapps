import 'package:flutter/material.dart';

enum ThemeType { free, premium }

class CustomTheme {
  final String id;
  final String name;
  final String description;
  final int cost; // In Rage Coins
  final ThemeType type;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;
  final LinearGradient backgroundGradient;
  final String? particleStyle;
  final String iconEmoji;

  const CustomTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.type,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.backgroundGradient,
    this.particleStyle,
    required this.iconEmoji,
  });
}

class AppThemes {
  static const List<CustomTheme> all = [
    CustomTheme(
      id: 'default',
      name: 'Classic Rage',
      description: 'The original fury experience',
      cost: 0,
      type: ThemeType.free,
      primaryColor: Color(0xFFFF6B00),
      accentColor: Color(0xFFFF0000),
      backgroundColor: Color(0xFF0A0A0F),
      cardColor: Color(0xFF1A1A2E),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A0A2A), Color(0xFF0A0A0F)],
      ),
      iconEmoji: '🔥',
    ),
    CustomTheme(
      id: 'neon_cyber',
      name: 'Neon Cyber',
      description: 'Cyberpunk vibes with electric colors',
      cost: 500,
      type: ThemeType.premium,
      primaryColor: Color(0xFF00FFFF),
      accentColor: Color(0xFFFF00FF),
      backgroundColor: Color(0xFF0D0221),
      cardColor: Color(0xFF1A0533),
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D0221), Color(0xFF240046)],
      ),
      particleStyle: 'neon',
      iconEmoji: '⚡',
    ),
    CustomTheme(
      id: 'ocean_depths',
      name: 'Ocean Depths',
      description: 'Calm your rage with deep sea blues',
      cost: 300,
      type: ThemeType.premium,
      primaryColor: Color(0xFF00CED1),
      accentColor: Color(0xFF4169E1),
      backgroundColor: Color(0xFF001F3F),
      cardColor: Color(0xFF002952),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF001F3F), Color(0xFF003366)],
      ),
      particleStyle: 'bubbles',
      iconEmoji: '🌊',
    ),
    CustomTheme(
      id: 'toxic_waste',
      name: 'Toxic Waste',
      description: 'Radioactive green destruction',
      cost: 400,
      type: ThemeType.premium,
      primaryColor: Color(0xFF39FF14),
      accentColor: Color(0xFFADFF2F),
      backgroundColor: Color(0xFF0D1F0D),
      cardColor: Color(0xFF1A331A),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D1F0D), Color(0xFF1A3D1A)],
      ),
      particleStyle: 'toxic',
      iconEmoji: '☢️',
    ),
    CustomTheme(
      id: 'royal_gold',
      name: 'Royal Gold',
      description: 'Destroy in style with golden elegance',
      cost: 750,
      type: ThemeType.premium,
      primaryColor: Color(0xFFFFD700),
      accentColor: Color(0xFFFFA500),
      backgroundColor: Color(0xFF1A1500),
      cardColor: Color(0xFF332B00),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A1500), Color(0xFF332B00)],
      ),
      particleStyle: 'sparkle',
      iconEmoji: '👑',
    ),
    CustomTheme(
      id: 'blood_moon',
      name: 'Blood Moon',
      description: 'Dark and ominous destruction',
      cost: 600,
      type: ThemeType.premium,
      primaryColor: Color(0xFF8B0000),
      accentColor: Color(0xFFDC143C),
      backgroundColor: Color(0xFF0F0000),
      cardColor: Color(0xFF1F0A0A),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F0000), Color(0xFF2B0000)],
      ),
      particleStyle: 'blood',
      iconEmoji: '🩸',
    ),
    CustomTheme(
      id: 'galaxy',
      name: 'Galaxy',
      description: 'Cosmic destruction across the universe',
      cost: 1000,
      type: ThemeType.premium,
      primaryColor: Color(0xFF9370DB),
      accentColor: Color(0xFFE6E6FA),
      backgroundColor: Color(0xFF0B0B1A),
      cardColor: Color(0xFF16162B),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B0B1A), Color(0xFF1A0A2E)],
      ),
      particleStyle: 'stars',
      iconEmoji: '🌌',
    ),
    CustomTheme(
      id: 'ice_storm',
      name: 'Ice Storm',
      description: 'Freeze your enemies with cold fury',
      cost: 450,
      type: ThemeType.premium,
      primaryColor: Color(0xFF87CEEB),
      accentColor: Color(0xFFADD8E6),
      backgroundColor: Color(0xFF0A1520),
      cardColor: Color(0xFF152535),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1520), Color(0xFF1A2D40)],
      ),
      particleStyle: 'snowflake',
      iconEmoji: '❄️',
    ),
  ];

  static CustomTheme getTheme(String id) {
    return all.firstWhere(
      (theme) => theme.id == id,
      orElse: () => all.first,
    );
  }

  static List<CustomTheme> get freeThemes =>
      all.where((t) => t.type == ThemeType.free).toList();

  static List<CustomTheme> get premiumThemes =>
      all.where((t) => t.type == ThemeType.premium).toList();
}
