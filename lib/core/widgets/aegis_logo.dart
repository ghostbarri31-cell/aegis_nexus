import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Brand mark — shield motif with gradient accent.
class AegisLogo extends StatelessWidget {
  const AegisLogo({
    super.key,
    this.size = 48,
    this.showWordmark = true,
    this.compact = false,
  });

  final double size;
  final bool showWordmark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final icon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: AppColors.accentGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGlow,
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        Icons.shield_outlined,
        color: Colors.white,
        size: size * 0.55,
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          curve: Curves.easeOutCubic,
        );

    if (!showWordmark || compact) {
      return icon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.accentGradient.createShader(bounds),
              child: Text(
                AppConstants.appName.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                      color: Colors.white,
                    ),
              ),
            ),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideX(
          begin: -0.05,
          end: 0,
          curve: Curves.easeOutCubic,
        );
  }
}
