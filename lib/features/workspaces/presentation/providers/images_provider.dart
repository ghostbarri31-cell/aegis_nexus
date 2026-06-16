import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/image_generation.dart';

/// Provider for managing Images workspace state.
/// 
/// Handles image generation history, collections, and generation parameters.
/// Future: Integration with image generation providers (DALL-E, Midjourney, Stable Diffusion),
/// style presets, batch generation, and image editing tools.
class ImagesProvider with ChangeNotifier {
  final List<ImageGeneration> _generations = [];
  final List<ImageCollection> _collections = [];
  ImageGeneration? _selectedGeneration;
  ImageCollection? _selectedCollection;
  bool _isGenerating = false;

  List<ImageGeneration> get generations => _generations;
  List<ImageCollection> get collections => _collections;
  ImageGeneration? get selectedGeneration => _selectedGeneration;
  ImageCollection? get selectedCollection => _selectedCollection;
  bool get isGenerating => _isGenerating;

  /// Generate a new image.
  /// 
  /// Future: Connect to actual image generation APIs.
  void generateImage({
    required String prompt,
    String? negativePrompt,
    ImageStyle? style,
    AspectRatio? aspectRatio,
    Map<String, dynamic>? parameters,
  }) {
    _isGenerating = true;
    notifyListeners();

    // Simulate generation - future: actual API call
    final generation = ImageGeneration(
      id: const Uuid().v4(),
      prompt: prompt,
      imageUrl: 'https://via.placeholder.com/512', // Placeholder
      createdAt: DateTime.now(),
      status: GenerationStatus.completed,
      negativePrompt: negativePrompt,
      style: style,
      aspectRatio: aspectRatio,
      parameters: parameters,
    );

    _generations.insert(0, generation);
    _selectedGeneration = generation;
    _isGenerating = false;
    notifyListeners();
  }

  /// Select an image generation.
  void selectGeneration(String generationId) {
    _selectedGeneration = _generations.firstWhere(
      (g) => g.id == generationId,
      orElse: () => _generations.first,
    );
    notifyListeners();
  }

  /// Delete an image generation.
  void deleteGeneration(String generationId) {
    _generations.removeWhere((g) => g.id == generationId);
    if (_selectedGeneration?.id == generationId) {
      _selectedGeneration = _generations.isNotEmpty ? _generations.first : null;
    }
    notifyListeners();
  }

  /// Create a new collection.
  ImageCollection createCollection({
    required String name,
    String? description,
  }) {
    final collection = ImageCollection(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      description: description,
    );
    _collections.add(collection);
    _selectedCollection = collection;
    notifyListeners();
    return collection;
  }

  /// Select a collection.
  void selectCollection(String collectionId) {
    _selectedCollection = _collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => _collections.first,
    );
    notifyListeners();
  }

  /// Add an image to a collection.
  void addToCollection(String generationId, String collectionId) {
    final collectionIndex = _collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;

    final updated = _collections[collectionIndex].copyWith(
      imageIds: [..._collections[collectionIndex].imageIds, generationId],
    );

    _collections[collectionIndex] = updated;
    if (_selectedCollection?.id == collectionId) {
      _selectedCollection = updated;
    }
    notifyListeners();
  }

  /// Delete a collection.
  void deleteCollection(String collectionId) {
    _collections.removeWhere((c) => c.id == collectionId);
    if (_selectedCollection?.id == collectionId) {
      _selectedCollection = _collections.isNotEmpty ? _collections.first : null;
    }
    notifyListeners();
  }

  /// Get generations filtered by collection.
  List<ImageGeneration> getGenerationsInCollection(String collectionId) {
    final collection = _collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => _collections.first,
    );
    return _generations.where((g) => collection.imageIds.contains(g.id)).toList();
  }
}
