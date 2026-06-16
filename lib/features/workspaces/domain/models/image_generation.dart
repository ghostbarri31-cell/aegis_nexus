import 'package:equatable/equatable.dart';

/// Image generation model for the Images workspace.
/// 
/// Represents a generated image with metadata, prompt,
/// and generation parameters.
class ImageGeneration extends Equatable {
  const ImageGeneration({
    required this.id,
    required this.prompt,
    required this.imageUrl,
    required this.createdAt,
    this.status = GenerationStatus.completed,
    this.negativePrompt,
    this.style,
    this.aspectRatio,
    this.provider,
    this.model,
    this.parameters,
  });

  final String id;
  final String prompt;
  final String imageUrl;
  final DateTime createdAt;
  final GenerationStatus status;
  final String? negativePrompt;
  final ImageStyle? style;
  final AspectRatio? aspectRatio;
  final String? provider;
  final String? model;
  final Map<String, dynamic>? parameters;

  ImageGeneration copyWith({
    String? id,
    String? prompt,
    String? imageUrl,
    DateTime? createdAt,
    GenerationStatus? status,
    String? negativePrompt,
    ImageStyle? style,
    AspectRatio? aspectRatio,
    String? provider,
    String? model,
    Map<String, dynamic>? parameters,
  }) {
    return ImageGeneration(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      style: style ?? this.style,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  List<Object?> get props => [
        id,
        prompt,
        imageUrl,
        createdAt,
        status,
        negativePrompt,
        style,
        aspectRatio,
        provider,
        model,
        parameters,
      ];
}

/// Status of image generation.
enum GenerationStatus {
  pending,
  generating,
  completed,
  failed,
}

/// Image style presets.
/// 
/// Future: Custom style training, style transfer,
// and community style sharing.
enum ImageStyle {
  realistic,
  artistic,
  anime,
  3d,
  minimalist,
  abstract,
  vintage,
  cyberpunk,
  fantasy,
  portrait,
}

/// Aspect ratio options.
enum AspectRatio {
  square,
  portrait,
  landscape,
  wide,
}

/// Image collection for organizing generations.
class ImageCollection extends Equatable {
  const ImageCollection({
    required this.id,
    required this.name,
    required this.createdAt,
    this.imageIds = const [],
    this.description,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> imageIds;
  final String? description;

  ImageCollection copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? imageIds,
    String? description,
  }) {
    return ImageCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      imageIds: imageIds ?? this.imageIds,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, imageIds, description];
}
