import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/image_generation.dart';
import '../providers/images_provider.dart';

/// Images workspace screen.
/// 
/// Purpose: Image generation, logos, visual concepts, illustrations and design tasks.
/// 
/// Features:
/// - Image generation with parameters
/// - Gallery layout for viewing generations
/// - Collection management
/// - Generation history
/// 
/// Future: Integration with image generation providers (DALL-E, Midjourney, Stable Diffusion),
/// style presets, batch generation, image editing tools, and advanced gallery features.
class ImagesWorkspaceScreen extends StatelessWidget {
  const ImagesWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ImagesProvider>();
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
                // Generation panel
                _GenerationPanel(
                  isGenerating: provider.isGenerating,
                  onGenerate: (prompt) => provider.generateImage(prompt: prompt),
                ),
                const Divider(height: 1),
                // Gallery
                Expanded(
                  child: provider.generations.isEmpty
                      ? _EmptyGalleryState()
                      : _ImageGallery(generations: provider.generations),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context, ImagesProvider provider) {
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
          child: collections.isEmpty
              ? const Center(
                  child: Text(
                    'No collections yet',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return _CollectionTile(
                      collection: collection,
                      isSelected: selectedCollection?.id == collection.id,
                      onTap: () => onSelectCollection(collection.id),
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
              Icons.folder_outlined,
              size: 18,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                collection.name,
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

class _GenerationPanel extends StatelessWidget {
  const _GenerationPanel({
    required this.isGenerating,
    required this.onGenerate,
  });

  final bool isGenerating;
  final Function(String) onGenerate;

  @override
  Widget build(BuildContext context) {
    final promptController = TextEditingController();

    return GlassContainer(
      borderRadius: 0,
      blur: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: promptController,
              decoration: InputDecoration(
                hintText: 'Describe the image you want to generate...',
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
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: isGenerating
                ? null
                : () {
                    if (promptController.text.isNotEmpty) {
                      onGenerate(promptController.text);
                      promptController.clear();
                    }
                  },
            icon: isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(isGenerating ? 'Generating...' : 'Generate'),
          ),
        ],
      ),
    );
  }
}

class _EmptyGalleryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: AppColors.textMuted,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 24),
          Text(
            'Images Workspace',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Generate images using the panel above',
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

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.generations});

  final List generations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: generations.length,
        itemBuilder: (context, index) {
          final generation = generations[index];
          return _ImageCard(generation: generation)
              .animate()
              .fadeIn(delay: (50 * index).ms, duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
        },
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.generation});

  final dynamic generation;

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
                  Icons.image_outlined,
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
                  generation.prompt,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 2,
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
                      _formatDate(generation.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

