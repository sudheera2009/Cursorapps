import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0B0F14);
  static const Color surface = Color(0xFF141A22);
  static const Color surfaceAlt = Color(0xFF1B232E);
  static const Color border = Color(0xFF283242);

  static const Color primary = Color(0xFF2FD3C6); // teal
  static const Color secondary = Color(0xFF4C8DFF); // blue
  static const Color accent = Color(0xFFFFB020); // amber

  static const Color textPrimary = Color(0xFFF3F6FA);
  static const Color textSecondary = Color(0xFFA6B2C2);
  static const Color textMuted = Color(0xFF6B7787);

  static const Color success = Color(0xFF35D07F);
  static const Color danger = Color(0xFFFF5C6C);
}

class AppTheme {
  static TextStyle get headline => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get title => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get subtitle => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  static TextStyle get number => GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.5,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        textTheme: TextTheme(
          headlineLarge: headline,
          titleLarge: title,
          titleMedium: subtitle,
          bodyLarge: body,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: title,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.primary,
          thumbColor: AppColors.primary,
        ),
      );
}
