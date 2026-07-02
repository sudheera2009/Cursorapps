import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RageLevel {
  calm,
  annoyed,
  heated,
  furious,
  nuclear,
}

class RageColors {
  static const Map<RageLevel, Color> primary = {
    RageLevel.calm: Color(0xFF00D4FF),
    RageLevel.annoyed: Color(0xFF00FFD4),
    RageLevel.heated: Color(0xFFFF9800),
    RageLevel.furious: Color(0xFFF44336),
    RageLevel.nuclear: Color(0xFFFFFFFF),
  };

  static const Map<RageLevel, Color> glow = {
    RageLevel.calm: Color(0x4000D4FF),
    RageLevel.annoyed: Color(0x6000FFD4),
    RageLevel.heated: Color(0x80FF9800),
    RageLevel.furious: Color(0xA0F44336),
    RageLevel.nuclear: Color(0xFFFFD700),
  };

  static const Map<RageLevel, Color> background = {
    RageLevel.calm: Color(0xFF0A1628),
    RageLevel.annoyed: Color(0xFF0A1620),
    RageLevel.heated: Color(0xFF1A0A0A),
    RageLevel.furious: Color(0xFF2A0505),
    RageLevel.nuclear: Color(0xFF3A1A00),
  };

  static Color getPrimary(RageLevel level) => primary[level]!;
  static Color getGlow(RageLevel level) => glow[level]!;
  static Color getBackground(RageLevel level) => background[level]!;

  static Color lerpPrimary(double ragePercent) {
    if (ragePercent < 0.2) {
      return Color.lerp(primary[RageLevel.calm], primary[RageLevel.annoyed], ragePercent / 0.2)!;
    } else if (ragePercent < 0.4) {
      return Color.lerp(primary[RageLevel.annoyed], primary[RageLevel.heated], (ragePercent - 0.2) / 0.2)!;
    } else if (ragePercent < 0.6) {
      return Color.lerp(primary[RageLevel.heated], primary[RageLevel.furious], (ragePercent - 0.4) / 0.2)!;
    } else if (ragePercent < 0.8) {
      return Color.lerp(primary[RageLevel.furious], primary[RageLevel.nuclear], (ragePercent - 0.6) / 0.2)!;
    } else {
      return primary[RageLevel.nuclear]!;
    }
  }

  static Color lerpBackground(double ragePercent) {
    if (ragePercent < 0.25) {
      return Color.lerp(background[RageLevel.calm], background[RageLevel.annoyed], ragePercent / 0.25)!;
    } else if (ragePercent < 0.5) {
      return Color.lerp(background[RageLevel.annoyed], background[RageLevel.heated], (ragePercent - 0.25) / 0.25)!;
    } else if (ragePercent < 0.75) {
      return Color.lerp(background[RageLevel.heated], background[RageLevel.furious], (ragePercent - 0.5) / 0.25)!;
    } else {
      return Color.lerp(background[RageLevel.furious], background[RageLevel.nuclear], (ragePercent - 0.75) / 0.25)!;
    }
  }

  static RageLevel getLevel(double ragePercent) {
    if (ragePercent < 0.2) return RageLevel.calm;
    if (ragePercent < 0.4) return RageLevel.annoyed;
    if (ragePercent < 0.6) return RageLevel.heated;
    if (ragePercent < 0.8) return RageLevel.furious;
    return RageLevel.nuclear;
  }
}

class AppTheme {
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color cardBorder = Color(0xFF2A2A4E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF707070);

  static TextStyle get headlineStyle => GoogleFonts.bebasNeue(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: 2,
      );

  static TextStyle get titleStyle => GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      );

  static TextStyle get subtitleStyle => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  static TextStyle get bodyStyle => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        color: textSecondary,
      );

  static TextStyle get numberStyle => GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      );

  static TextStyle get damageStyle => GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B00),
          secondary: Color(0xFF00D4FF),
          surface: cardBackground,
        ),
        textTheme: TextTheme(
          headlineLarge: headlineStyle,
          titleLarge: titleStyle,
          titleMedium: subtitleStyle,
          bodyLarge: bodyStyle,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
}
