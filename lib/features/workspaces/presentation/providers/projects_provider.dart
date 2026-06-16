import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/project.dart';

/// Provider for managing Projects workspace state.
/// 
/// This is the core of Aegis Nexus - handles projects, objectives, missions,
/// progress tracking, assets, and platform integrations.
/// 
/// Future: AI agent execution, automated mission scheduling,
/// platform API integrations (TikTok, Instagram, YouTube, Shopify),
/// and long-term project memory.
class ProjectsProvider with ChangeNotifier {
  final List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;

  /// Create a new project.
  Project createProject({
    required String name,
    required String description,
    List<String>? tags,
  }) {
    final project = Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: ProjectStatus.active,
      tags: tags ?? [],
    );
    _projects.add(project);
    _selectedProject = project;
    notifyListeners();
    return project;
  }

  /// Select a project.
  void selectProject(String projectId) {
    _selectedProject = _projects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => _projects.first,
    );
    notifyListeners();
  }

  /// Delete a project.
  void deleteProject(String projectId) {
    _projects.removeWhere((p) => p.id == projectId);
    if (_selectedProject?.id == projectId) {
      _selectedProject = _projects.isNotEmpty ? _projects.first : null;
    }
    notifyListeners();
  }

  /// Add an objective to the selected project.
  Objective addObjective({
    required String title,
    required String description,
    required DateTime targetDate,
    ObjectivePriority priority = ObjectivePriority.medium,
  }) {
    if (_selectedProject == null) {
      throw Exception('No project selected');
    }

    final objective = Objective(
      id: const Uuid().v4(),
      title: title,
      description: description,
      targetDate: targetDate,
      priority: priority,
    );

    final updated = _selectedProject!.copyWith(
      objectives: [..._selectedProject!.objectives, objective],
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
    return objective;
  }

  /// Update objective progress.
  void updateObjectiveProgress(String objectiveId, double progress) {
    if (_selectedProject == null) return;

    final objectives = _selectedProject!.objectives.map((o) {
      if (o.id == objectiveId) {
        return o.copyWith(progress: progress);
      }
      return o;
    }).toList();

    _recalculateProgress(objectives);
  }

  /// Complete an objective.
  void completeObjective(String objectiveId) {
    if (_selectedProject == null) return;

    final objectives = _selectedProject!.objectives.map((o) {
      if (o.id == objectiveId) {
        return o.copyWith(
          status: ObjectiveStatus.completed,
          progress: 1.0,
        );
      }
      return o;
    }).toList();

    _recalculateProgress(objectives);
  }

  /// Add a mission to the selected project.
  Mission addMission({
    required String title,
    required String description,
    required DateTime dueDate,
    MissionPriority priority = MissionPriority.medium,
    String? assignedAgentId,
  }) {
    if (_selectedProject == null) {
      throw Exception('No project selected');
    }

    final mission = Mission(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      assignedAgentId: assignedAgentId,
    );

    final updated = _selectedProject!.copyWith(
      missions: [..._selectedProject!.missions, mission],
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
    return mission;
  }

  /// Update mission status.
  void updateMissionStatus(String missionId, MissionStatus status) {
    if (_selectedProject == null) return;

    final missions = _selectedProject!.missions.map((m) {
      if (m.id == missionId) {
        return m.copyWith(status: status);
      }
      return m;
    }).toList();

    final updated = _selectedProject!.copyWith(
      missions: missions,
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
  }

  /// Add a checkpoint to a mission.
  void addMissionCheckpoint(String missionId, String title) {
    if (_selectedProject == null) return;

    final missions = _selectedProject!.missions.map((m) {
      if (m.id == missionId) {
        return m.copyWith(
          checkpoints: [
            ...m.checkpoints,
            MissionCheckpoint(
              id: const Uuid().v4(),
              title: title,
              completedAt: DateTime.now(),
            ),
          ],
        );
      }
      return m;
    }).toList();

    final updated = _selectedProject!.copyWith(
      missions: missions,
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
  }

  /// Add an asset to the selected project.
  void addAsset(ProjectAsset asset) {
    if (_selectedProject == null) return;

    final updated = _selectedProject!.copyWith(
      assets: [..._selectedProject!.assets, asset],
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
  }

  /// Connect a platform to the selected project.
  /// 
  /// Future: OAuth flow and API integration for platforms
  /// (TikTok, Instagram, YouTube, Shopify, etc.)
  void connectPlatform(PlatformType platform, String accountName) {
    if (_selectedProject == null) return;

    final connectedPlatform = ConnectedPlatform(
      id: const Uuid().v4(),
      platform: platform,
      status: ConnectionStatus.connected,
      connectedAt: DateTime.now(),
      accountName: accountName,
      capabilities: _getDefaultCapabilities(platform),
    );

    final updated = _selectedProject!.copyWith(
      connectedPlatforms: [..._selectedProject!.connectedPlatforms, connectedPlatform],
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
  }

  /// Disconnect a platform.
  void disconnectPlatform(String platformId) {
    if (_selectedProject == null) return;

    final updated = _selectedProject!.copyWith(
      connectedPlatforms: _selectedProject!.connectedPlatforms
          .where((p) => p.id != platformId)
          .toList(),
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
  }

  /// Update project status.
  void updateProjectStatus(ProjectStatus status) {
    if (_selectedProject == null) return;

    final updated = _selectedProject!.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
  }

  void _recalculateProgress(List<Objective> objectives) {
    if (_selectedProject == null) return;

    final completed = objectives.where((o) => o.status == ObjectiveStatus.completed).length;
    final total = objectives.length;
    final overallProgress = total > 0 ? completed / total : 0.0;

    final missionsCompleted = _selectedProject!.missions
        .where((m) => m.status == MissionStatus.completed)
        .length;
    final missionsTotal = _selectedProject!.missions.length;

    final progress = ProjectProgress(
      overallProgress: overallProgress,
      objectivesCompleted: completed,
      objectivesTotal: total,
      missionsCompleted: missionsCompleted,
      missionsTotal: missionsTotal,
      lastUpdated: DateTime.now(),
    );

    final updated = _selectedProject!.copyWith(
      objectives: objectives,
      progress: progress,
      updatedAt: DateTime.now(),
    );

    _updateProject(updated);
  }

  void _updateProject(Project updated) {
    final index = _projects.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _projects[index] = updated;
      _selectedProject = updated;
      notifyListeners();
    }
  }

  List<PlatformCapability> _getDefaultCapabilities(PlatformType platform) {
    switch (platform) {
      case PlatformType.tiktok:
      case PlatformType.instagram:
      case PlatformType.youtube:
        return [PlatformCapability.posting, PlatformCapability.analytics, PlatformCapability.scheduling];
      case PlatformType.shopify:
        return [PlatformCapability.commerce, PlatformCapability.analytics];
      case PlatformType.twitter:
      case PlatformType.linkedin:
      case PlatformType.facebook:
        return [PlatformCapability.posting, PlatformCapability.analytics, PlatformCapability.advertising];
      case PlatformType.custom:
        return [PlatformCapability.posting, PlatformCapability.analytics];
    }
  }
}
