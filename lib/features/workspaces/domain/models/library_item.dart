import 'package:equatable/equatable.dart';

/// Library item model for the Library workspace.
/// 
/// Represents any asset stored in the centralized library:
/// documents, images, videos, conversations, and generated content.
class LibraryItem extends Equatable {
  const LibraryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.createdAt,
    this.sizeBytes,
    this.description,
    this.tags = const [],
    this.collectionIds = const [],
    this.metadata,
  });

  final String id;
  final String name;
  final LibraryItemType type;
  final String url;
  final DateTime createdAt;
  final int? sizeBytes;
  final String? description;
  final List<String> tags;
  final List<String> collectionIds;
  final Map<String, dynamic>? metadata;

  LibraryItem copyWith({
    String? id,
    String? name,
    LibraryItemType? type,
    String? url,
    DateTime? createdAt,
    int? sizeBytes,
    String? description,
    List<String>? tags,
    List<String>? collectionIds,
    Map<String, dynamic>? metadata,
  }) {
    return LibraryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      collectionIds: collectionIds ?? this.collectionIds,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        url,
        createdAt,
        sizeBytes,
        description,
        tags,
        collectionIds,
        metadata,
      ];
}

/// Type of library item.
enum LibraryItemType {
  document,
  image,
  video,
  audio,
  conversation,
  code,
  dataset,
  report,
  other,
}

/// Collection for organizing library items.
/// 
/// Future: Smart collections based on AI analysis,
// automatic categorization, and collection sharing.
class LibraryCollection extends Equatable {
  const LibraryCollection({
    required this.id,
    required this.name,
    required this.createdAt,
    this.itemIds = const [],
    this.description,
    this.color,
    this.isSmartCollection = false,
    this.smartCriteria,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> itemIds;
  final String? description;
  final String? color;
  final bool isSmartCollection;
  final Map<String, dynamic>? smartCriteria;

  LibraryCollection copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? itemIds,
    String? description,
    String? color,
    bool? isSmartCollection,
    Map<String, dynamic>? smartCriteria,
  }) {
    return LibraryCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      itemIds: itemIds ?? this.itemIds,
      description: description ?? this.description,
      color: color ?? this.color,
      isSmartCollection: isSmartCollection ?? this.isSmartCollection,
      smartCriteria: smartCriteria ?? this.smartCriteria,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        itemIds,
        description,
        color,
        isSmartCollection,
        smartCriteria,
      ];
}

/// Tag for categorizing library items.
class LibraryTag extends Equatable {
  const LibraryTag({
    required this.id,
    required this.name,
    required this.color,
    this.itemCount = 0,
  });

  final String id;
  final String name;
  final String color;
  final int itemCount;

  LibraryTag copyWith({
    String? id,
    String? name,
    String? color,
    int? itemCount,
  }) {
    return LibraryTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  List<Object?> get props => [id, name, color, itemCount];
}
