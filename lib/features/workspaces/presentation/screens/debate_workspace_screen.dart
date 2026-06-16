import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/workspace_type.dart';
import '../providers/debate_provider.dart';

/// AI Debate workspace screen.
/// 
/// Purpose: Multi-AI debate mode for comparing different model responses.
/// 
/// Features:
/// - Multi-model response comparison
/// - Side-by-side response viewing
/// - Synthesis generation
/// - Model selection and configuration
/// 
/// Future: Integration with multiple AI providers (Groq, Gemini, OpenAI, Claude, DeepSeek),
/// response analysis and scoring, consensus building tools, and debate history export.
class DebateWorkspaceScreen extends StatelessWidget {
  const DebateWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DebateProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return SafeArea(
      child: Row(
        children: [
          // Sessions sidebar
          if (isWide)
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border(
                  right: BorderSide(color: AppColors.glassBorder),
                ),
              ),
              child: _SessionsSidebar(
                sessions: provider.sessions,
                selectedSession: provider.selectedSession,
                onSelectSession: (id) => provider.selectSession(id),
                onDeleteSession: (id) => provider.deleteSession(id),
                onCreateSession: () => _showCreateSessionDialog(context, provider),
              ),
            ),
          // Main content
          Expanded(
            child: provider.selectedSession == null
                ? _EmptyState(onCreateSession: () => _showCreateSessionDialog(context, provider))
                : _DebateSessionView(
                    session: provider.selectedSession!,
                    availableModels: provider.availableModels,
                    isDebating: provider.isDebating,
                    onStartDebate: (modelIds) => provider.startDebate(modelIds),
                    onGenerateSynthesis: () => provider.generateSynthesis(),
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context, DebateProvider provider) {
    final topicController = TextEditingController();
    final promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Debate Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: 'Topic'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: promptController,
              decoration: const InputDecoration(labelText: 'Prompt'),
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
              if (topicController.text.isNotEmpty && promptController.text.isNotEmpty) {
                provider.createSession(
                  topic: topicController.text,
                  prompt: promptController.text,
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

class _SessionsSidebar extends StatelessWidget {
  const _SessionsSidebar({
    required this.sessions,
    required this.selectedSession,
    required this.onSelectSession,
    required this.onDeleteSession,
    required this.onCreateSession,
  });

  final List sessions;
  final dynamic selectedSession;
  final Function(String) onSelectSession;
  final Function(String) onDeleteSession;
  final VoidCallback onCreateSession;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: onCreateSession,
            icon: const Icon(Icons.add),
            label: const Text('New Debate'),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: sessions.isEmpty
              ? const Center(
                  child: Text(
                    'No debates yet',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return _SessionTile(
                      session: session,
                      isSelected: selectedSession?.id == session.id,
                      onTap: () => onSelectSession(session.id),
                      onDelete: () => onDeleteSession(session.id),
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

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final dynamic session;
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
              Icons.compare_arrows_rounded,
              size: 18,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.topic,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${session.responses.length} responses',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
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
  const _EmptyState({required this.onCreateSession});

  final VoidCallback onCreateSession;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            size: 64,
            color: AppColors.textMuted,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 24),
          Text(
            'AI Debate Workspace',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Compare AI responses side-by-side',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreateSession,
            icon: const Icon(Icons.add),
            label: const Text('Create Debate Session'),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _DebateSessionView extends StatelessWidget {
  const _DebateSessionView({
    required this.session,
    required this.availableModels,
    required this.isDebating,
    required this.onStartDebate,
    required this.onGenerateSynthesis,
  });

  final dynamic session;
  final List availableModels;
  final bool isDebating;
  final Function(List<String>) onStartDebate;
  final VoidCallback onGenerateSynthesis;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.topic,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                session.prompt,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Model selection
        if (session.responses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: _ModelSelectionPanel(
              availableModels: availableModels,
              isDebating: isDebating,
              onStartDebate: onStartDebate,
            ),
          ),
        // Responses
        Expanded(
          child: session.responses.isEmpty
              ? const SizedBox()
              : _ResponsesGrid(
                  responses: session.responses,
                  synthesis: session.synthesis,
                  onGenerateSynthesis: onGenerateSynthesis,
                ),
        ),
      ],
    );
  }
}

class _ModelSelectionPanel extends StatelessWidget {
  const _ModelSelectionPanel({
    required this.availableModels,
    required this.isDebating,
    required this.onStartDebate,
  });

  final List availableModels;
  final bool isDebating;
  final Function(List<String>) onStartDebate;

  @override
  Widget build(BuildContext context) {
    final selectedModels = <String>{};

    return GlassContainer(
      borderRadius: 12,
      blur: 12,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select AI Models',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableModels.map((model) {
              return FilterChip(
                label: Text('${model.name} (${model.provider})'),
                selected: selectedModels.contains(model.id),
                onSelected: (selected) {
                  if (selected) {
                    selectedModels.add(model.id);
                  } else {
                    selectedModels.remove(model.id);
                  }
                },
                checkmarkColor: AppColors.accent,
                selectedColor: AppColors.glassFill,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isDebating || selectedModels.isEmpty
                ? null
                : () => onStartDebate(selectedModels.toList()),
            icon: isDebating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(isDebating ? 'Debating...' : 'Start Debate'),
          ),
        ],
      ),
    );
  }
}

class _ResponsesGrid extends StatelessWidget {
  const _ResponsesGrid({
    required this.responses,
    required this.synthesis,
    required this.onGenerateSynthesis,
  });

  final List responses;
  final dynamic synthesis;
  final VoidCallback onGenerateSynthesis;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Synthesis panel
        if (synthesis != null)
          Padding(
            padding: const EdgeInsets.all(24),
            child: GlassContainer(
              borderRadius: 12,
              blur: 12,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Synthesis',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    synthesis.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (synthesis.consensusPoints.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Consensus:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...synthesis.consensusPoints.map((point) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(point)),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FilledButton.icon(
              onPressed: onGenerateSynthesis,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Synthesis'),
            ),
          ),
        // Responses grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: responses.length,
              itemBuilder: (context, index) {
                final response = responses[index];
                return _ResponseCard(response: response)
                    .animate()
                    .fadeIn(delay: (100 * index).ms, duration: 300.ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({required this.response});

  final dynamic response;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 12,
      blur: 8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  response.provider,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              if (response.latencyMs != null)
                Text(
                  '${response.latencyMs}ms',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response.modelName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                response.content,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

