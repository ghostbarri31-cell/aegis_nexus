import 'package:flutter/material.dart';

/// Resolved color set for the current brightness.
class ResolvedColors {
  const ResolvedColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.sidebar,
    required this.glassFill,
    required this.glassBorder,
    required this.glassHighlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.backgroundGradient,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color sidebar;
  final Color glassFill;
  final Color glassBorder;
  final Color glassHighlight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final LinearGradient backgroundGradient;
}

/// Dark futuristic palette for Aegis Nexus.
abstract final class AppColors {
  // ── Dark palette (unchanged) ──────────────────────────────────────────
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

  // ── Light palette ─────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightSidebar = Color(0xFFF1F5F9);

  static const Color lightGlassFill = Color(0x0A000000);
  static const Color lightGlassBorder = Color(0x1A000000);
  static const Color lightGlassHighlight = Color(0x14000000);

  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Resolved helpers ──────────────────────────────────────────────────

  static const _dark = ResolvedColors(
    background: background,
    surface: surface,
    surfaceElevated: surfaceElevated,
    sidebar: sidebar,
    glassFill: glassFill,
    glassBorder: glassBorder,
    glassHighlight: glassHighlight,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textMuted: textMuted,
    backgroundGradient: backgroundGradient,
  );

  static const _light = ResolvedColors(
    background: lightBackground,
    surface: lightSurface,
    surfaceElevated: lightSurfaceElevated,
    sidebar: lightSidebar,
    glassFill: lightGlassFill,
    glassBorder: lightGlassBorder,
    glassHighlight: lightGlassHighlight,
    textPrimary: lightTextPrimary,
    textSecondary: lightTextSecondary,
    textMuted: lightTextMuted,
    backgroundGradient: lightBackgroundGradient,
  );

  /// Returns the resolved color set for the current theme brightness.
  static ResolvedColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _dark : _light;
  }
}
