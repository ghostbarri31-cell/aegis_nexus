import 'package:flutter/foundation.dart';
import '../../domain/models/workspace_type.dart';

/// Provider for managing Nexus workspace state.
/// 
/// This provider handles workspace selection and navigation state.
/// Future phases will expand this to include:
/// - Workspace-specific data persistence
/// - Workspace preferences and settings
/// - Cross-workspace data sharing
/// - Workspace activity tracking
class WorkspaceProvider with ChangeNotifier {
  WorkspaceType _currentWorkspace = WorkspaceType.discussion;

  WorkspaceType get currentWorkspace => _currentWorkspace;

  /// Select a workspace by type.
  void selectWorkspace(WorkspaceType workspace) {
    if (_currentWorkspace != workspace) {
      _currentWorkspace = workspace;
      notifyListeners();
    }
  }

  /// Select a workspace by route path.
  void selectByRoute(String route) {
    final workspace = WorkspaceType.fromRoute(route);
    if (workspace != null) {
      _currentWorkspace = workspace;
      notifyListeners();
    }
  }

  /// Get all available workspaces in navigation order.
  List<WorkspaceType> get allWorkspaces => WorkspaceType.values;

  /// Check if a workspace is currently active.
  bool isActive(WorkspaceType workspace) => _currentWorkspace == workspace;
}
