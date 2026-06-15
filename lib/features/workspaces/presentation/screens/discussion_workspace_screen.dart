import 'package:flutter/material.dart';

import '../../domain/models/workspace_type.dart';
import '../widgets/workspace_placeholder.dart';

/// Discussion workspace screen.
/// 
/// Purpose: General conversations, questions, assistance and daily AI interactions.
/// This workspace will eventually integrate with the existing chat system
/// to provide a dedicated space for casual AI interactions.
class DiscussionWorkspaceScreen extends StatelessWidget {
  const DiscussionWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkspacePlaceholder(
      workspace: WorkspaceType.discussion,
      customMessage: 'Integration with chat system coming soon',
    );
  }
}
