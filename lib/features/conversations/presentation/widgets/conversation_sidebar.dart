import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aegis_logo.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../domain/models/conversation_item.dart';
import '../../../workspaces/presentation/widgets/workspace_nav_section.dart';

class ConversationSidebar extends StatelessWidget {
  const ConversationSidebar({
    super.key,
    this.expanded = true,
    this.onToggle,
  });

  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final location = GoRouterState.of(context).uri.path;
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.sidebar,
        border: Border(right: BorderSide(color: colors.glassBorder)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                expanded ? 20 : 12,
                20,
                expanded ? 20 : 12,
                8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AegisLogo(
                          size: expanded ? 40 : 36,
                          showWordmark: expanded,
                          compact: !expanded,
                        ),
                      ),
                    ),
                  ),
                  if (onToggle != null)
                    IconButton(
                      icon: Icon(
                        expanded
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                      ),
                      onPressed: onToggle,
                      tooltip: expanded ? 'Collapse sidebar' : 'Expand sidebar',
                    ),
                ],
              ),
            ),
            if (expanded) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _NewChatButton(
                  onPressed: () => context.read<ChatProvider>().createNew(),
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'HISTORY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textMuted,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: chat.conversations.isEmpty
                    ? Center(
                        child: Text(
                          'No conversations yet',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.textMuted,
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: chat.conversations.length,
                        itemBuilder: (context, index) {
                          final item = chat.conversations[index];
                          return _ConversationTile(
                            item: item,
                            onTap: () => chat.select(item.id),
                            onDelete: () => _confirmDelete(context, item),
                          )
                              .animate()
                              .fadeIn(delay: (60 * index).ms, duration: 280.ms);
                        },
                      ),
              ),
            ] else
              Expanded(
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'New conversation',
                      onPressed: () => context.read<ChatProvider>().createNew(),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            WorkspaceNavSection(expanded: expanded, currentPath: location),
            _SidebarNav(expanded: expanded, currentPath: location),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ConversationItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text('Remove "${item.title}" and all its messages.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ChatProvider>().deleteConversation(item.id);
    }
  }
}

class _NewChatButton extends StatelessWidget {
  const _NewChatButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGlow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'New chat',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final ConversationItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GlassContainer(
        onTap: onTap,
        borderRadius: 12,
        blur: 8,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: item.isActive ? AppColors.accent : AppColors.of(context).textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: item.isActive
                          ? AppColors.of(context).textPrimary
                          : AppColors.of(context).textSecondary,
                      fontWeight:
                          item.isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.of(context).textMuted,
              onPressed: onDelete,
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNav extends StatelessWidget {
  const _SidebarNav({required this.expanded, required this.currentPath});

  final bool expanded;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentPath == AppRouter.home,
            expanded: expanded,
            onTap: () => context.go(AppRouter.home),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Paramètres',
            selected: currentPath == AppRouter.settings,
            expanded: expanded,
            onTap: () => context.go(AppRouter.settings),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profil',
            selected: currentPath == AppRouter.profile,
            expanded: expanded,
            onTap: () => context.go(AppRouter.profile),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.of(context).glassFill : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 14 : 8,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.accent : AppColors.of(context).textSecondary,
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? AppColors.of(context).textPrimary
                              : AppColors.of(context).textSecondary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
