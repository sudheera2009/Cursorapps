import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global visual language for BARREL.
///
/// The app leans into a "professional energy trading desk" aesthetic: near
/// black backgrounds, subtle slate panels, an amber "crude" accent and a teal
/// "gas" accent, with clear green/red semantics for gains and losses.
class AppColors {
  static const Color background = Color(0xFF0A0C10);
  static const Color backgroundAlt = Color(0xFF10141C);
  static const Color card = Color(0xFF161B26);
  static const Color cardAlt = Color(0xFF1D2431);
  static const Color cardBorder = Color(0xFF283142);

  // Crude oil = amber, natural gas = teal.
  static const Color crude = Color(0xFFF6A609);
  static const Color gas = Color(0xFF19C6C9);
  static const Color primary = Color(0xFFF6A609);
  static const Color accent = Color(0xFF19C6C9);

  static const Color textPrimary = Color(0xFFF2F5FA);
  static const Color textSecondary = Color(0xFFA7B0C0);
  static const Color textMuted = Color(0xFF677185);

  static const Color up = Color(0xFF2ECC71);
  static const Color down = Color(0xFFFF5A5F);
  static const Color neutral = Color(0xFF8A93A6);

  /// Color for a signed value: green up, red down, muted flat.
  static Color forChange(num change) {
    if (change > 0) return up;
    if (change < 0) return down;
    return neutral;
  }
}

class AppTheme {
  static TextStyle get displayStyle => GoogleFonts.spaceGrotesk(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 1,
      );

  static TextStyle get headlineStyle => GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleStyle => GoogleFonts.spaceGrotesk(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get subtitleStyle => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyStyle => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelStyle => GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.5,
      );

  /// Tabular figures for prices/numbers so digits don't jitter as they tick.
  static TextStyle mono({
    double size = 15,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.card,
          error: AppColors.down,
        ),
        textTheme: TextTheme(
          headlineLarge: headlineStyle,
          titleLarge: titleStyle,
          titleMedium: subtitleStyle,
          bodyLarge: bodyStyle,
          bodyMedium: bodyStyle,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: titleStyle,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        dividerColor: AppColors.cardBorder,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
      );
}
