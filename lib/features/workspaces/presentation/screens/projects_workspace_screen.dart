import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/workspace_type.dart';
import '../providers/projects_provider.dart';

/// Projects workspace screen.
/// 
/// Purpose: Long-term objectives and mission execution.
/// 
/// This is the core of Aegis Nexus - designed to become the central hub
/// for all AI-driven project management and execution.
/// 
/// Features:
/// - Project dashboard with objectives and missions
/// - Progress tracking and analytics
/// - Asset management
/// - Platform integration preparation
/// 
/// Future: AI agents for autonomous task execution, connected platforms
/// (TikTok, Instagram, YouTube, Shopify), long-term project memory,
/// team collaboration, resource allocation, and milestone tracking.
class ProjectsWorkspaceScreen extends StatelessWidget {
  const ProjectsWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return SafeArea(
      child: Row(
        children: [
          // Projects sidebar
          if (isWide)
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border(
                  right: BorderSide(color: AppColors.glassBorder),
                ),
              ),
              child: _ProjectsSidebar(
                projects: provider.projects,
                selectedProject: provider.selectedProject,
                onSelectProject: (id) => provider.selectProject(id),
                onDeleteProject: (id) => provider.deleteProject(id),
                onCreateProject: () => _showCreateProjectDialog(context, provider),
              ),
            ),
          // Main content
          Expanded(
            child: provider.selectedProject == null
                ? _EmptyState(onCreateProject: () => _showCreateProjectDialog(context, provider))
                : _ProjectDashboard(project: provider.selectedProject!),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context, ProjectsProvider provider) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                provider.createProject(
                  name: nameController.text,
                  description: descriptionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _ProjectsSidebar extends StatelessWidget {
  const _ProjectsSidebar({
    required this.projects,
    required this.selectedProject,
    required this.onSelectProject,
    required this.onDeleteProject,
    required this.onCreateProject,
  });

  final List projects;
  final dynamic selectedProject;
  final Function(String) onSelectProject;
  final Function(String) onDeleteProject;
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: onCreateProject,
            icon: const Icon(Icons.add),
            label: const Text('New Project'),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: projects.isEmpty
              ? const Center(
                  child: Text(
                    'No projects yet',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return _ProjectTile(
                      project: project,
                      isSelected: selectedProject?.id == project.id,
                      onTap: () => onSelectProject(project.id),
                      onDelete: () => onDeleteProject(project.id),
                    )
                        .animate()
                        .fadeIn(delay: (50 * index).ms, duration: 200.ms);
                  },
                ),
        ),
      ],
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.project,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic project;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GlassContainer(
        onTap: onTap,
        borderRadius: 8,
        blur: 8,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.flag_rounded,
              size: 18,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${(project.progress.overallProgress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.textMuted,
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateProject});

  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_rounded,
            size: 64,
            color: AppColors.textMuted,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 24),
          Text(
            'Projects Workspace',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Manage long-term objectives and missions',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreateProject,
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _ProjectDashboard extends StatelessWidget {
  const _ProjectDashboard({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    _ProgressIndicator(progress: project.progress.overallProgress),
                  ],
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  borderRadius: 12,
                  blur: 12,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Future: AI agents, platform integrations (TikTok, Instagram, YouTube, Shopify), and long-term project memory.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tabs
          const TabBar(
            tabs: [
              Tab(text: 'Objectives'),
              Tab(text: 'Missions'),
              Tab(text: 'Assets'),
              Tab(text: 'Platforms'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ObjectivesTab(objectives: project.objectives),
                _MissionsTab(missions: project.missions),
                _AssetsTab(assets: project.assets),
                _PlatformsTab(platforms: project.connectedPlatforms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 12,
      blur: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '${(progress * 100).toInt()}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _ObjectivesTab extends StatelessWidget {
  const _ObjectivesTab({required this.objectives});

  final List objectives;

  @override
  Widget build(BuildContext context) {
    if (objectives.isEmpty) {
      return const Center(
        child: Text(
          'No objectives yet',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: objectives.length,
      itemBuilder: (context, index) {
        final objective = objectives[index];
        return GlassContainer(
          borderRadius: 12,
          blur: 8,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      objective.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(objective.priority).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      objective.priority.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getPriorityColor(objective.priority),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                objective.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: objective.progress,
                backgroundColor: AppColors.glassBorder,
                valueColor: AlwaysStoppedAnimation(AppColors.accent),
              ),
              const SizedBox(height: 4),
              Text(
                '${(objective.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPriorityColor(dynamic priority) {
    switch (priority.toString().split('.').last) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      default:
        return AppColors.success;
    }
  }
}

class _MissionsTab extends StatelessWidget {
  const _MissionsTab({required this.missions});

  final List missions;

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return const Center(
        child: Text(
          'No missions yet',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return GlassContainer(
          borderRadius: 12,
          blur: 8,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(mission.status),
                    size: 16,
                    color: _getStatusColor(mission.status),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mission.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(mission.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      mission.status.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(mission.status),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                mission.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              if (mission.checkpoints.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Checkpoints: ${mission.checkpoints.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(dynamic status) {
    switch (status.toString().split('.').last) {
      case 'completed':
        return Icons.check_circle;
      case 'inProgress':
        return Icons.sync;
      case 'failed':
        return Icons.error;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status.toString().split('.').last) {
      case 'completed':
        return AppColors.success;
      case 'inProgress':
        return AppColors.accent;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}

class _AssetsTab extends StatelessWidget {
  const _AssetsTab({required this.assets});

  final List assets;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(
        child: Text(
          'No assets yet',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return GlassContainer(
          borderRadius: 12,
          blur: 8,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                _getAssetIcon(asset.type),
                size: 32,
                color: AppColors.accent,
              ),
              const SizedBox(height: 8),
              Text(
                asset.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getAssetIcon(dynamic type) {
    switch (type.toString().split('.').last) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'document':
        return Icons.description;
      case 'code':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _PlatformsTab extends StatelessWidget {
  const _PlatformsTab({required this.platforms});

  final List platforms;

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No platforms connected',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'Future: Connect TikTok, Instagram, YouTube, Shopify',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: platforms.length,
      itemBuilder: (context, index) {
        final platform = platforms[index];
        return GlassContainer(
          borderRadius: 12,
          blur: 8,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                _getPlatformIcon(platform.platform),
                size: 24,
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform.platform.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (platform.accountName != null)
                      Text(
                        platform.accountName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.success,
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getPlatformIcon(dynamic platform) {
    switch (platform.toString().split('.').last) {
      case 'tiktok':
        return Icons.music_note;
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube':
        return Icons.play_circle;
      case 'shopify':
        return Icons.shopping_cart;
      default:
        return Icons.public;
    }
  }
}

