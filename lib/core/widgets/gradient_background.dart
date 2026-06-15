import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ambient background with gradient and accent orbs.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: colors.backgroundGradient),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentSecondary.withValues(alpha: isDark ? 0.08 : 0.04),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
