import 'package:flutter/material.dart';

/// Dark futuristic palette for Aegis Nexus.
abstract final class AppColors {
  static const Color background = Color(0xFF050508);
  static const Color surface = Color(0xFF0C0C10);
  static const Color surfaceElevated = Color(0xFF14141A);
  static const Color sidebar = Color(0xFF0A0A0E);

  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x22FFFFFF);
  static const Color glassHighlight = Color(0x33FFFFFF);

  static const Color textPrimary = Color(0xFFF4F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color accent = Color(0xFF6366F1);
  static const Color accentGlow = Color(0x406366F1);
  static const Color accentSecondary = Color(0xFF22D3EE);

  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF87171);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF050508), Color(0xFF0A0A12), Color(0xFF050508)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
