import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/workspace_type.dart';
import '../providers/workspace_provider.dart';

/// Workspace navigation section for the sidebar.
/// 
/// Displays all Nexus workspaces in a compact, accessible format.
/// This is the primary entry point to the AI Operating System structure.
class WorkspaceNavSection extends StatelessWidget {
  const WorkspaceNavSection({
    super.key,
    required this.expanded,
    required this.currentPath,
  });

  final bool expanded;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'NEXUS WORKSPACES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ...WorkspaceType.values.map(
            (workspace) => _WorkspaceNavItem(
              workspace: workspace,
              selected: currentPath == workspace.route,
              expanded: expanded,
              onTap: () {
                context.read<WorkspaceProvider>().selectWorkspace(workspace);
                context.go(workspace.route);
              },
            )
                .animate()
                .fadeIn(
                  delay: (250 + WorkspaceType.values.indexOf(workspace) * 50).ms,
                  duration: 280.ms,
                )
                .slideX(begin: -0.1, end: 0),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceNavItem extends StatelessWidget {
  const _WorkspaceNavItem({
    required this.workspace,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final WorkspaceType workspace;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.glassFill : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 14 : 8,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  workspace.icon,
                  size: 22,
                  color: selected ? AppColors.accent : AppColors.textSecondary,
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      workspace.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
