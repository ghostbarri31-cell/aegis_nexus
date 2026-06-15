import 'package:flutter/material.dart';

import '../../domain/models/workspace_type.dart';
import '../widgets/workspace_placeholder.dart';

/// Images workspace screen.
/// 
/// Purpose: Image generation, logos, visual concepts, illustrations and design tasks.
/// Future: Integration with image generation providers, prompt templates,
/// style presets, image editing tools, and gallery management.
class ImagesWorkspaceScreen extends StatelessWidget {
  const ImagesWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkspacePlaceholder(
      workspace: WorkspaceType.images,
      customMessage: 'Image generation integration coming soon',
    );
  }
}
