import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/workspace_type.dart';

/// Reusable placeholder content for workspace screens.
/// 
/// Displays workspace information and a "coming soon" message
/// while maintaining the premium dark futuristic design.
class WorkspacePlaceholder extends StatelessWidget {
  const WorkspacePlaceholder({
    super.key,
    required this.workspace,
    this.customMessage,
  });

  final WorkspaceType workspace;
  final String? customMessage;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 20,
              vertical: isWide ? 48 : 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Workspace icon
                Container(
                  width: isWide ? 120 : 80,
                  height: isWide ? 120 : 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGlow,
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    workspace.icon,
                    size: isWide ? 56 : 36,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                const SizedBox(height: 32),
                // Workspace name
                Text(
                  workspace.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 12),
                // Workspace description
                Text(
                  workspace.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),
                // Coming soon badge
                GlassContainer(
                  borderRadius: 20,
                  blur: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.construction_rounded,
                        size: 20,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        customMessage ?? 'Coming in future updates',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),
                // Additional info
                Text(
                  'This workspace is part of the Nexus AI Operating System foundation.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ).animate().fadeIn(delay: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
