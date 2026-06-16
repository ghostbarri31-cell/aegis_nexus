import 'package:equatable/equatable.dart';

/// Debate session model for the AI Debate workspace.
/// 
/// Represents a multi-AI debate where different models
/// analyze the same problem and responses are compared.
class DebateSession extends Equatable {
  const DebateSession({
    required this.id,
    required this.topic,
    required this.prompt,
    required this.createdAt,
    required this.updatedAt,
    this.status = DebateStatus.active,
    this.responses = const [],
    this.synthesis,
  });

  final String id;
  final String topic;
  final String prompt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DebateStatus status;
  final List<ModelResponse> responses;
  final DebateSynthesis? synthesis;

  DebateSession copyWith({
    String? id,
    String? topic,
    String? prompt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DebateStatus? status,
    List<ModelResponse>? responses,
    DebateSynthesis? synthesis,
  }) {
    return DebateSession(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      prompt: prompt ?? this.prompt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      responses: responses ?? this.responses,
      synthesis: synthesis ?? this.synthesis,
    );
  }

  @override
  List<Object?> get props => [
        id,
        topic,
        prompt,
        createdAt,
        updatedAt,
        status,
        responses,
        synthesis,
      ];
}

/// Status of a debate session.
enum DebateStatus {
  active,
  completed,
  archived,
}

/// Response from a specific AI model.
/// 
/// Future: Support for Groq, Gemini, OpenAI, Claude, DeepSeek,
// and other providers with standardized response format.
class ModelResponse extends Equatable {
  const ModelResponse({
    required this.id,
    required this.modelId,
    required this.modelName,
    required this.provider,
    required this.content,
    required this.timestamp,
    this.status = ResponseStatus.completed,
    this.tokenCount,
    this.latencyMs,
    this.metadata,
  });

  final String id;
  final String modelId;
  final String modelName;
  final String provider;
  final String content;
  final DateTime timestamp;
  final ResponseStatus status;
  final int? tokenCount;
  final int? latencyMs;
  final Map<String, dynamic>? metadata;

  ModelResponse copyWith({
    String? id,
    String? modelId,
    String? modelName,
    String? provider,
    String? content,
    DateTime? timestamp,
    ResponseStatus? status,
    int? tokenCount,
    int? latencyMs,
    Map<String, dynamic>? metadata,
  }) {
    return ModelResponse(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      provider: provider ?? this.provider,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      tokenCount: tokenCount ?? this.tokenCount,
      latencyMs: latencyMs ?? this.latencyMs,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        modelId,
        modelName,
        provider,
        content,
        timestamp,
        status,
        tokenCount,
        latencyMs,
        metadata,
      ];
}

/// Status of a model response.
enum ResponseStatus {
  pending,
  generating,
  completed,
  failed,
}

/// Synthesis of debate responses.
/// 
/// Future: AI-powered synthesis that compares responses,
// identifies consensus, highlights differences, and provides
// a unified analysis from all models.
class DebateSynthesis extends Equatable {
  const DebateSynthesis({
    required this.id,
    required this.content,
    required this.generatedAt,
    this.consensusPoints = const [],
    this.differences = const [],
    this.recommendation,
  });

  final String id;
  final String content;
  final DateTime generatedAt;
  final List<String> consensusPoints;
  final List<String> differences;
  final String? recommendation;

  DebateSynthesis copyWith({
    String? id,
    String? content,
    DateTime? generatedAt,
    List<String>? consensusPoints,
    List<String>? differences,
    String? recommendation,
  }) {
    return DebateSynthesis(
      id: id ?? this.id,
      content: content ?? this.content,
      generatedAt: generatedAt ?? this.generatedAt,
      consensusPoints: consensusPoints ?? this.consensusPoints,
      differences: differences ?? this.differences,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        generatedAt,
        consensusPoints,
        differences,
        recommendation,
      ];
}

/// Available AI models for debate.
/// 
/// Future: Dynamic model discovery, custom model registration,
// and provider-specific configuration.
class AvailableModel extends Equatable {
  const AvailableModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.capabilities,
    this.isEnabled = true,
  });

  final String id;
  final String name;
  final String provider;
  final List<ModelCapability> capabilities;
  final bool isEnabled;

  @override
  List<Object?> get props => [id, name, provider, capabilities, isEnabled];
}

/// Model capabilities.
enum ModelCapability {
  textGeneration,
  codeGeneration,
  reasoning,
  multimodal,
  webSearch,
}
