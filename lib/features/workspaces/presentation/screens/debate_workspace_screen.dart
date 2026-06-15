import 'package:flutter/material.dart';

import '../../domain/models/workspace_type.dart';
import '../widgets/workspace_placeholder.dart';

/// AI Debate workspace screen.
/// 
/// Purpose: Multi-AI debate mode for comparing different model responses.
/// 
/// Future architecture:
/// - Side-by-side comparison of responses from multiple AI providers
/// - Supported providers: Groq, Gemini, OpenAI, Claude, DeepSeek
/// - Response analysis and scoring
/// - Consensus building tools
/// - Debate history and export
class DebateWorkspaceScreen extends StatelessWidget {
  const DebateWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkspacePlaceholder(
      workspace: WorkspaceType.debate,
      customMessage: 'Multi-model comparison coming soon',
    );
  }
}
