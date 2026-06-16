import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/library_item.dart';

/// Provider for managing Library workspace state.
/// 
/// Handles centralized storage for documents, images, videos, conversations,
/// and generated assets with collections and tags.
/// 
/// Future: Cloud synchronization, advanced search, AI-powered categorization,
/// smart collections, and version history.
class LibraryProvider with ChangeNotifier {
  final List<LibraryItem> _items = [];
  final List<LibraryCollection> _collections = [];
  final List<LibraryTag> _tags = [];
  LibraryCollection? _selectedCollection;
  bool _isLoading = false;

  List<LibraryItem> get items => _items;
  List<LibraryCollection> get collections => _collections;
  List<LibraryTag> get tags => _tags;
  LibraryCollection? get selectedCollection => _selectedCollection;
  bool get isLoading => _isLoading;

  /// Add an item to the library.
  LibraryItem addItem({
    required String name,
    required LibraryItemType type,
    required String url,
    String? description,
    List<String>? tags,
    int? sizeBytes,
    Map<String, dynamic>? metadata,
  }) {
    final item = LibraryItem(
      id: const Uuid().v4(),
      name: name,
      type: type,
      url: url,
      createdAt: DateTime.now(),
      description: description,
      tags: tags ?? [],
      sizeBytes: sizeBytes,
      metadata: metadata,
    );

    _items.add(item);
    
    // Update tag counts
    for (final tagName in item.tags) {
      _updateTagCount(tagName, 1);
    }

    notifyListeners();
    return item;
  }

  /// Delete an item from the library.
  void deleteItem(String itemId) {
    final item = _items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => _items.first,
    );

    // Update tag counts
    for (final tagName in item.tags) {
      _updateTagCount(tagName, -1);
    }

    _items.removeWhere((i) => i.id == itemId);
    
    // Remove from collections
    _collections = _collections.map((c) {
      return c.copyWith(
        itemIds: c.itemIds.where((id) => id != itemId).toList(),
      );
    }).toList();

    notifyListeners();
  }

  /// Create a new collection.
  LibraryCollection createCollection({
    required String name,
    String? description,
    String? color,
    bool isSmartCollection = false,
    Map<String, dynamic>? smartCriteria,
  }) {
    final collection = LibraryCollection(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      description: description,
      color: color,
      isSmartCollection: isSmartCollection,
      smartCriteria: smartCriteria,
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

  /// Add an item to a collection.
  void addToCollection(String itemId, String collectionId) {
    final collectionIndex = _collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;

    if (_collections[collectionIndex].itemIds.contains(itemId)) return;

    final updated = _collections[collectionIndex].copyWith(
      itemIds: [..._collections[collectionIndex].itemIds, itemId],
    );

    _collections[collectionIndex] = updated;
    if (_selectedCollection?.id == collectionId) {
      _selectedCollection = updated;
    }
    notifyListeners();
  }

  /// Remove an item from a collection.
  void removeFromCollection(String itemId, String collectionId) {
    final collectionIndex = _collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;

    final updated = _collections[collectionIndex].copyWith(
      itemIds: _collections[collectionIndex].itemIds.where((id) => id != itemId).toList(),
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

  /// Add a tag to an item.
  void addTagToItem(String itemId, String tagName) {
    final itemIndex = _items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return;

    if (_items[itemIndex].tags.contains(tagName)) return;

    final updated = _items[itemIndex].copyWith(
      tags: [..._items[itemIndex].tags, tagName],
    );

    _items[itemIndex] = updated;
    _updateTagCount(tagName, 1);
    notifyListeners();
  }

  /// Remove a tag from an item.
  void removeTagFromItem(String itemId, String tagName) {
    final itemIndex = _items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return;

    final updated = _items[itemIndex].copyWith(
      tags: _items[itemIndex].tags.where((t) => t != tagName).toList(),
    );

    _items[itemIndex] = updated;
    _updateTagCount(tagName, -1);
    notifyListeners();
  }

  /// Create a new tag.
  LibraryTag createTag({
    required String name,
    required String color,
  }) {
    final tag = LibraryTag(
      id: const Uuid().v4(),
      name: name,
      color: color,
    );
    _tags.add(tag);
    notifyListeners();
    return tag;
  }

  /// Get items filtered by collection.
  List<LibraryItem> getItemsInCollection(String collectionId) {
    final collection = _collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => _collections.first,
    );
    return _items.where((i) => collection.itemIds.contains(i.id)).toList();
  }

  /// Get items filtered by tag.
  List<LibraryItem> getItemsWithTag(String tagName) {
    return _items.where((i) => i.tags.contains(tagName)).toList();
  }

  /// Get items filtered by type.
  List<LibraryItem> getItemsByType(LibraryItemType type) {
    return _items.where((i) => i.type == type).toList();
  }

  /// Search items by name or description.
  List<LibraryItem> searchItems(String query) {
    final lowerQuery = query.toLowerCase();
    return _items.where((i) {
      return i.name.toLowerCase().contains(lowerQuery) ||
          (i.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void _updateTagCount(String tagName, int delta) {
    final tagIndex = _tags.indexWhere((t) => t.name == tagName);
    if (tagIndex != -1) {
      final updated = _tags[tagIndex].copyWith(
        itemCount: _tags[tagIndex].itemCount + delta,
      );
      _tags[tagIndex] = updated;
    }
  }
}
