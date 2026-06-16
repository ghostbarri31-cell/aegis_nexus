import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/workspace_type.dart';
import '../providers/research_provider.dart';

/// Research workspace screen.
/// 
/// Purpose: Deep research, analysis, reports, market studies and investigations.
/// 
/// Features:
/// - Research session management
/// - Source tracking and citation
/// - Finding organization
/// - Report generation
/// 
/// Future: Web search integration, automated citation management,
/// collaborative research, and advanced report templates.
class ResearchWorkspaceScreen extends StatelessWidget {
  const ResearchWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResearchProvider>();
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
                : _ResearchSessionView(session: provider.selectedSession!),
          ),
        ],
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context, ResearchProvider provider) {
    final titleController = TextEditingController();
    final queryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Research Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: queryController,
              decoration: const InputDecoration(labelText: 'Research Query'),
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
              if (titleController.text.isNotEmpty && queryController.text.isNotEmpty) {
                provider.createSession(
                  title: titleController.text,
                  query: queryController.text,
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
            label: const Text('New Session'),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: sessions.isEmpty
              ? const Center(
                  child: Text(
                    'No research sessions yet',
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
              Icons.search_rounded,
              size: 18,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    session.query,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            Icons.search_rounded,
            size: 64,
            color: AppColors.textMuted,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 24),
          Text(
            'Research Workspace',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Create a research session to begin deep analysis',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreateSession,
            icon: const Icon(Icons.add),
            label: const Text('Create Research Session'),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _ResearchSessionView extends StatelessWidget {
  const _ResearchSessionView({required this.session});

  final dynamic session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            session.query,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
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
                    'Research session active. Future: Web search integration, source tracking, and automated report generation.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Sources'),
                      Tab(text: 'Findings'),
                      Tab(text: 'Report'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _SourcesTab(sources: session.sources),
                        _FindingsTab(findings: session.findings),
                        _ReportTab(report: session.report),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcesTab extends StatelessWidget {
  const _SourcesTab({required this.sources});

  final List sources;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const Center(
        child: Text(
          'No sources yet',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sources.length,
      itemBuilder: (context, index) {
        final source = sources[index];
        return GlassContainer(
          borderRadius: 8,
          blur: 8,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                source.url,
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
}

class _FindingsTab extends StatelessWidget {
  const _FindingsTab({required this.findings});

  final List findings;

  @override
  Widget build(BuildContext context) {
    if (findings.isEmpty) {
      return const Center(
        child: Text(
          'No findings yet',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: findings.length,
      itemBuilder: (context, index) {
        final finding = findings[index];
        return GlassContainer(
          borderRadius: 8,
          blur: 8,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(
            finding.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }
}

class _ReportTab extends StatelessWidget {
  const _ReportTab({required this.report});

  final dynamic report;

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No report generated yet',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                // Future: Generate report
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Report'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        borderRadius: 12,
        blur: 12,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              report.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
