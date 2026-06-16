import 'package:equatable/equatable.dart';

/// Project model for the Projects workspace.
/// 
/// This is the core of Aegis Nexus - designed to become the central hub
/// for all AI-driven project management and execution.
class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.status = ProjectStatus.active,
    this.objectives = const [],
    this.missions = const [],
    this.progress = const ProjectProgress(),
    this.assets = const [],
    this.connectedPlatforms = const [],
    this.tags = const [],
  });

  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectStatus status;
  final List<Objective> objectives;
  final List<Mission> missions;
  final ProjectProgress progress;
  final List<ProjectAsset> assets;
  final List<ConnectedPlatform> connectedPlatforms;
  final List<String> tags;

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectStatus? status,
    List<Objective>? objectives,
    List<Mission>? missions,
    ProjectProgress? progress,
    List<ProjectAsset>? assets,
    List<ConnectedPlatform>? connectedPlatforms,
    List<String>? tags,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      objectives: objectives ?? this.objectives,
      missions: missions ?? this.missions,
      progress: progress ?? this.progress,
      assets: assets ?? this.assets,
      connectedPlatforms: connectedPlatforms ?? this.connectedPlatforms,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        updatedAt,
        status,
        objectives,
        missions,
        progress,
        assets,
        connectedPlatforms,
        tags,
      ];
}

/// Status of a project.
enum ProjectStatus {
  active,
  paused,
  completed,
  archived,
}

/// Objective within a project.
/// 
/// High-level goals that guide project direction.
/// Future: AI-powered objective generation, SMART goal templates,
// and objective dependency tracking.
class Objective extends Equatable {
  const Objective({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDate,
    this.status = ObjectiveStatus.active,
    this.priority = ObjectivePriority.medium,
    this.progress = 0.0,
    this.missionIds = const [],
  });

  final String id;
  final String title;
  final String description;
  final DateTime targetDate;
  final ObjectiveStatus status;
  final ObjectivePriority priority;
  final double progress;
  final List<String> missionIds;

  Objective copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? targetDate,
    ObjectiveStatus? status,
    ObjectivePriority? priority,
    double? progress,
    List<String>? missionIds,
  }) {
    return Objective(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      missionIds: missionIds ?? this.missionIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        targetDate,
        status,
        priority,
        progress,
        missionIds,
      ];
}

/// Status of an objective.
enum ObjectiveStatus {
  active,
  completed,
  paused,
  cancelled,
}

/// Priority level for objectives.
enum ObjectivePriority {
  low,
  medium,
  high,
  critical,
}

/// Mission within a project.
/// 
/// Specific actionable tasks that contribute to objectives.
/// Future: AI agent execution, automated mission scheduling,
// and mission dependency graphs.
class Mission extends Equatable {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    this.status = MissionStatus.pending,
    this.priority = MissionPriority.medium,
    this.assignedAgentId,
    this.dependencies = const [],
    this.checkpoints = const [],
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime dueDate;
  final MissionStatus status;
  final MissionPriority priority;
  final String? assignedAgentId;
  final List<String> dependencies;
  final List<MissionCheckpoint> checkpoints;

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    MissionStatus? status,
    MissionPriority? priority,
    String? assignedAgentId,
    List<String>? dependencies,
    List<MissionCheckpoint>? checkpoints,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      dependencies: dependencies ?? this.dependencies,
      checkpoints: checkpoints ?? this.checkpoints,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        createdAt,
        dueDate,
        status,
        priority,
        assignedAgentId,
        dependencies,
        checkpoints,
      ];
}

/// Status of a mission.
enum MissionStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// Priority level for missions.
enum MissionPriority {
  low,
  medium,
  high,
  urgent,
}

/// Checkpoint within a mission.
class MissionCheckpoint extends Equatable {
  const MissionCheckpoint({
    required this.id,
    required this.title,
    required this.completedAt,
    this.notes,
  });

  final String id;
  final String title;
  final DateTime completedAt;
  final String? notes;

  @override
  List<Object?> get props => [id, title, completedAt, notes];
}

/// Overall project progress tracking.
class ProjectProgress extends Equatable {
  const ProjectProgress({
    this.overallProgress = 0.0,
    this.objectivesCompleted = 0,
    this.objectivesTotal = 0,
    this.missionsCompleted = 0,
    this.missionsTotal = 0,
    this.lastUpdated,
  });

  final double overallProgress;
  final int objectivesCompleted;
  final int objectivesTotal;
  final int missionsCompleted;
  final int missionsTotal;
  final DateTime? lastUpdated;

  ProjectProgress copyWith({
    double? overallProgress,
    int? objectivesCompleted,
    int? objectivesTotal,
    int? missionsCompleted,
    int? missionsTotal,
    DateTime? lastUpdated,
  }) {
    return ProjectProgress(
      overallProgress: overallProgress ?? this.overallProgress,
      objectivesCompleted: objectivesCompleted ?? this.objectivesCompleted,
      objectivesTotal: objectivesTotal ?? this.objectivesTotal,
      missionsCompleted: missionsCompleted ?? this.missionsCompleted,
      missionsTotal: missionsTotal ?? this.missionsTotal,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        overallProgress,
        objectivesCompleted,
        objectivesTotal,
        missionsCompleted,
        missionsTotal,
        lastUpdated,
      ];
}

/// Asset associated with a project.
class ProjectAsset extends Equatable {
  const ProjectAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.createdAt,
    this.description,
    this.sizeBytes,
  });

  final String id;
  final String name;
  final AssetType type;
  final String url;
  final DateTime createdAt;
  final String? description;
  final int? sizeBytes;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        url,
        createdAt,
        description,
        sizeBytes,
      ];
}

/// Type of project asset.
enum AssetType {
  document,
  image,
  video,
  audio,
  code,
  dataset,
  other,
}

/// Connected platform integration.
/// 
/// Future: TikTok, Instagram, YouTube, Shopify, and other platforms
// with automated posting, analytics, and management.
class ConnectedPlatform extends Equatable {
  const ConnectedPlatform({
    required this.id,
    required this.platform,
    required this.status,
    required this.connectedAt,
    this.accountName,
    this.lastSync,
    this.capabilities = const [],
  });

  final String id;
  final PlatformType platform;
  final ConnectionStatus status;
  final DateTime connectedAt;
  final String? accountName;
  final DateTime? lastSync;
  final List<PlatformCapability> capabilities;

  ConnectedPlatform copyWith({
    String? id,
    PlatformType? platform,
    ConnectionStatus? status,
    DateTime? connectedAt,
    String? accountName,
    DateTime? lastSync,
    List<PlatformCapability>? capabilities,
  }) {
    return ConnectedPlatform(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      connectedAt: connectedAt ?? this.connectedAt,
      accountName: accountName ?? this.accountName,
      lastSync: lastSync ?? this.lastSync,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  @override
  List<Object?> get props => [
        id,
        platform,
        status,
        connectedAt,
        accountName,
        lastSync,
        capabilities,
      ];
}

/// Supported platform types.
enum PlatformType {
  tiktok,
  instagram,
  youtube,
  shopify,
  twitter,
  linkedin,
  facebook,
  custom,
}

/// Connection status for platforms.
enum ConnectionStatus {
  connected,
  disconnected,
  error,
  pending,
}

/// Platform capabilities.
enum PlatformCapability {
  posting,
  analytics,
  scheduling,
  messaging,
  commerce,
  advertising,
}
