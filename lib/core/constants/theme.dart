import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chromapulse/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const logoGradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, AppColors.accent3],
  );

  static const logoGradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent2, AppColors.gold],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gold, Color(0xFFFF9500)],
  );

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: Colors.black,
        secondary: AppColors.accent3,
        onSecondary: Colors.white,
        error: AppColors.accent2,
        surface: AppColors.surface,
        onSurface: AppColors.text,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
  }

  /// Monospace numeric style — use for score, combo, timer, accuracy values.
  static TextStyle mono({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.text,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
}
