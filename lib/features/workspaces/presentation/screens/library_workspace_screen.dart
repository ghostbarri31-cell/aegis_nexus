import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/workspace_type.dart';
import '../providers/library_provider.dart';

/// Library workspace screen.
/// 
/// Purpose: Centralized storage for documents, images, videos, and generated assets.
/// 
/// Features:
/// - Asset grid with filtering and search
/// - Collections for organizing assets
/// - Tag system for categorization
/// - File upload and management
/// 
/// Future: Integration with cloud storage, asset preview and editing,
/// sharing and export features, and advanced metadata management.
class LibraryWorkspaceScreen extends StatelessWidget {
  const LibraryWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return SafeArea(
      child: Row(
        children: [
          // Collections sidebar
          if (isWide)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border(
                  right: BorderSide(color: AppColors.glassBorder),
                ),
              ),
              child: _CollectionsSidebar(
                collections: provider.collections,
                selectedCollection: provider.selectedCollection,
                onSelectCollection: (id) => provider.selectCollection(id),
                onCreateCollection: () => _showCreateCollectionDialog(context, provider),
              ),
            ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Search and filter bar
                _SearchFilterBar(
                  searchQuery: provider.searchQuery,
                  selectedType: provider.selectedType,
                  onSearchChanged: provider.setSearchQuery,
                  onTypeChanged: provider.setFilterType,
                ),
                const Divider(height: 1),
                // Asset grid
                Expanded(
                  child: provider.filteredItems.isEmpty
                      ? _EmptyLibraryState()
                      : _AssetGrid(items: provider.filteredItems),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context, LibraryProvider provider) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
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
              if (nameController.text.isNotEmpty) {
                provider.createCollection(
                  name: nameController.text,
                  description: descriptionController.text,
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

class _CollectionsSidebar extends StatelessWidget {
  const _CollectionsSidebar({
    required this.collections,
    required this.selectedCollection,
    required this.onSelectCollection,
    required this.onCreateCollection,
  });

  final List collections;
  final dynamic selectedCollection;
  final Function(String) onSelectCollection;
  final VoidCallback onCreateCollection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: onCreateCollection,
            icon: const Icon(Icons.add),
            label: const Text('New Collection'),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: collections.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CollectionTile(
                  collection: null,
                  isSelected: selectedCollection == null,
                  onTap: () => onSelectCollection(''),
                ).animate().fadeIn(duration: 200.ms);
              }
              final collection = collections[index - 1];
              return _CollectionTile(
                collection: collection,
                isSelected: selectedCollection?.id == collection.id,
                onTap: () => onSelectCollection(collection.id),
              ).animate().fadeIn(delay: (50 * index).ms, duration: 200.ms);
            },
          ),
        ),
      ],
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.collection,
    required this.isSelected,
    required this.onTap,
  });

  final dynamic collection;
  final bool isSelected;
  final VoidCallback onTap;

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
              collection == null ? Icons.folder_open : Icons.folder_outlined,
              size: 18,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                collection == null ? 'All Items' : collection.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  const _SearchFilterBar({
    required this.searchQuery,
    required this.selectedType,
    required this.onSearchChanged,
    required this.onTypeChanged,
  });

  final String searchQuery;
  final dynamic selectedType;
  final Function(String) onSearchChanged;
  final Function(dynamic) onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      blur: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search assets...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton(
              value: selectedType,
              hint: const Text('Type'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'document', child: Text('Documents')),
                DropdownMenuItem(value: 'image', child: Text('Images')),
                DropdownMenuItem(value: 'video', child: Text('Videos')),
                DropdownMenuItem(value: 'audio', child: Text('Audio')),
              ],
              onChanged: onTypeChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textMuted,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 24),
          Text(
            'Library Workspace',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Your centralized asset storage',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _AssetGrid extends StatelessWidget {
  const _AssetGrid({required this.items});

  final List items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _AssetCard(item: item)
              .animate()
              .fadeIn(delay: (50 * index).ms, duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
        },
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 12,
      blur: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: AppColors.surfaceElevated,
              ),
              child: Center(
                child: Icon(
                  _getItemIcon(item.type),
                  size: 48,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.accent,
                                fontSize: 10,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getItemIcon(dynamic type) {
    switch (type.toString().split('.').last) {
      case 'document':
        return Icons.description;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).toInt()}w ago';
    }
  }
}

