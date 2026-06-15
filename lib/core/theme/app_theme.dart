import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
    );

    return _build(base, AppColors.textPrimary);
  }

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
    );

    return _build(base, AppColors.lightTextPrimary);
  }

  static ThemeData _build(ThemeData base, Color textColor) {
    final isDark = base.brightness == Brightness.dark;

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
      ),
      dividerColor: isDark ? AppColors.glassBorder : AppColors.lightGlassBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.glassFill : AppColors.lightGlassFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.glassBorder : AppColors.lightGlassBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.glassBorder : AppColors.lightGlassBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AppColors.surfaceElevated
            : const Color(0xFF1F2937),
      ),
    );
  }
}
