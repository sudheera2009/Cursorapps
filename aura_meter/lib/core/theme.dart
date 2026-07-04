import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global visual language for AURA METER.
///
/// The app leans into a "cosmic scanner" aesthetic: deep space backgrounds,
/// glowing neon orbs, and glassmorphic cards.
class AppColors {
  static const Color background = Color(0xFF07060F);
  static const Color backgroundAlt = Color(0xFF0E0B1E);
  static const Color card = Color(0xFF15122A);
  static const Color cardBorder = Color(0xFF2A2551);

  static const Color primary = Color(0xFF9D5CFF); // aura violet
  static const Color secondary = Color(0xFF00E5FF); // scanner cyan
  static const Color accent = Color(0xFFFF4FD8); // magenta pop
  static const Color gold = Color(0xFFFFD54A);

  static const Color textPrimary = Color(0xFFF5F3FF);
  static const Color textSecondary = Color(0xFFB8B2D8);
  static const Color textMuted = Color(0xFF6E6A8A);

  static const Color success = Color(0xFF4AE38C);
  static const Color danger = Color(0xFFFF5C7A);
}

class AppTheme {
  static TextStyle get displayStyle => GoogleFonts.orbitron(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: 2,
      );

  static TextStyle get headlineStyle => GoogleFonts.orbitron(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle get titleStyle => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get subtitleStyle => GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyStyle => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        color: AppColors.textSecondary,
      );

  static TextStyle get numberStyle => GoogleFonts.orbitron(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelStyle => GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 2,
      );

  static const Gradient spaceGradient = RadialGradient(
    center: Alignment(0, -0.3),
    radius: 1.4,
    colors: [
      Color(0xFF19122E),
      AppColors.background,
    ],
  );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.card,
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
          centerTitle: true,
        ),
      );
}
