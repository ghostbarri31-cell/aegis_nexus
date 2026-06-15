import 'package:flutter/material.dart';

/// Nexus workspace types - the foundation of the AI Operating System.
/// 
/// Each workspace represents a distinct mode of interaction with AI,
/// designed to scale into a full operating system experience.
enum WorkspaceType {
  /// General conversations, questions, assistance and daily AI interactions.
  discussion(
    id: 'discussion',
    name: 'Discussion',
    description: 'General conversations and daily AI interactions',
    icon: Icons.chat_bubble_outline_rounded,
    route: '/workspaces/discussion',
  ),

  /// Deep research, analysis, reports, market studies and investigations.
  research(
    id: 'research',
    name: 'Research',
    description: 'Deep research, analysis and investigations',
    icon: Icons.search_rounded,
    route: '/workspaces/research',
  ),

  /// Image generation, logos, visual concepts, illustrations and design tasks.
  images(
    id: 'images',
    name: 'Images',
    description: 'Image generation and visual design',
    icon: Icons.image_outlined,
    route: '/workspaces/images',
  ),

  /// Multi-AI debate mode for comparing different model responses.
  /// 
  /// Future: Side-by-side comparison of responses from multiple AI providers
  /// (Groq, Gemini, OpenAI, Claude, DeepSeek, etc.)
  debate(
    id: 'debate',
    name: 'AI Debate',
    description: 'Compare AI responses side-by-side',
    icon: Icons.compare_arrows_rounded,
    route: '/workspaces/debate',
  ),

  /// Long-term objectives and mission execution.
  /// 
  /// Future: Core of Aegis Nexus with support for:
  /// - Objectives and missions
  /// - AI agents
  /// - Progress tracking
  /// - Connected platforms (TikTok, Instagram, YouTube, Shopify, etc.)
  /// - Long-term project memory
  projects(
    id: 'projects',
    name: 'Projects',
    description: 'Long-term objectives and mission execution',
    icon: Icons.flag_rounded,
    route: '/workspaces/projects',
  ),

  /// Centralized storage for all Nexus assets.
  /// 
  /// Future: Unified library for conversations, documents, images,
  /// videos, and project assets with advanced search and organization.
  library(
    id: 'library',
    name: 'Library',
    description: 'Centralized storage for all assets',
    icon: Icons.folder_open_rounded,
    route: '/workspaces/library',
  );

  const WorkspaceType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String route;

  /// Get workspace by route path.
  static WorkspaceType? fromRoute(String route) {
    return WorkspaceType.values.firstWhere(
      (type) => type.route == route,
      orElse: () => WorkspaceType.discussion,
    );
  }

  /// Get workspace by ID.
  static WorkspaceType? fromId(String id) {
    try {
      return WorkspaceType.values.firstWhere((type) => type.id == id);
    } catch (_) {
      return null;
    }
  }
}
