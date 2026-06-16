import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/debate_session.dart';

/// Provider for managing AI Debate workspace state.
/// 
/// Handles debate sessions, multi-model responses, and synthesis generation.
/// Future: Integration with multiple AI providers (Groq, Gemini, OpenAI, Claude, DeepSeek),
/// side-by-side response comparison, and AI-powered synthesis.
class DebateProvider with ChangeNotifier {
  final List<DebateSession> _sessions = [];
  final List<AvailableModel> _availableModels = [];
  DebateSession? _selectedSession;
  bool _isDebating = false;

  List<DebateSession> get sessions => _sessions;
  List<AvailableModel> get availableModels => _availableModels;
  DebateSession? get selectedSession => _selectedSession;
  bool get isDebating => _isDebating;

  DebateProvider() {
    _initializeAvailableModels();
  }

  /// Initialize available AI models.
  /// 
  /// Future: Dynamic model discovery from provider APIs.
  void _initializeAvailableModels() {
    _availableModels.addAll([
      const AvailableModel(
        id: 'groq-llama3-70b',
        name: 'Llama 3 70B',
        provider: 'Groq',
        capabilities: [
          ModelCapability.textGeneration,
          ModelCapability.codeGeneration,
          ModelCapability.reasoning,
        ],
        isEnabled: true,
      ),
      const AvailableModel(
        id: 'gemini-pro',
        name: 'Gemini Pro',
        provider: 'Google',
        capabilities: [
          ModelCapability.textGeneration,
          ModelCapability.codeGeneration,
          ModelCapability.multimodal,
        ],
        isEnabled: true,
      ),
      const AvailableModel(
        id: 'gpt-4-turbo',
        name: 'GPT-4 Turbo',
        provider: 'OpenAI',
        capabilities: [
          ModelCapability.textGeneration,
          ModelCapability.codeGeneration,
          ModelCapability.reasoning,
          ModelCapability.webSearch,
        ],
        isEnabled: true,
      ),
      const AvailableModel(
        id: 'claude-3-opus',
        name: 'Claude 3 Opus',
        provider: 'Anthropic',
        capabilities: [
          ModelCapability.textGeneration,
          ModelCapability.codeGeneration,
          ModelCapability.reasoning,
        ],
        isEnabled: true,
      ),
      const AvailableModel(
        id: 'deepseek-coder',
        name: 'DeepSeek Coder',
        provider: 'DeepSeek',
        capabilities: [
          ModelCapability.textGeneration,
          ModelCapability.codeGeneration,
        ],
        isEnabled: true,
      ),
    ]);
  }

  /// Create a new debate session.
  DebateSession createSession({
    required String topic,
    required String prompt,
    List<String>? selectedModelIds,
  }) {
    final session = DebateSession(
      id: const Uuid().v4(),
      topic: topic,
      prompt: prompt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: DebateStatus.active,
    );
    _sessions.add(session);
    _selectedSession = session;
    notifyListeners();
    return session;
  }

  /// Start a debate with selected models.
  /// 
  /// Future: Connect to actual AI provider APIs.
  void startDebate(List<String> modelIds) {
    if (_selectedSession == null) return;
    
    _isDebating = true;
    notifyListeners();

    // Simulate responses - future: actual API calls
    final responses = <ModelResponse>[];
    for (final modelId in modelIds) {
      final model = _availableModels.firstWhere(
        (m) => m.id == modelId,
        orElse: () => _availableModels.first,
      );
      
      final response = ModelResponse(
        id: const Uuid().v4(),
        modelId: model.id,
        modelName: model.name,
        provider: model.provider,
        content: 'Response from ${model.name} on "${_selectedSession!.topic}"',
        timestamp: DateTime.now(),
        status: ResponseStatus.completed,
        tokenCount: 500,
        latencyMs: 1500,
      );
      responses.add(response);
    }

    final updated = _selectedSession!.copyWith(
      responses: responses,
      updatedAt: DateTime.now(),
    );

    _updateSession(updated);
    _isDebating = false;
    notifyListeners();
  }

  /// Generate synthesis of debate responses.
  /// 
  /// Future: AI-powered synthesis that compares responses,
  /// identifies consensus, highlights differences, and provides unified analysis.
  void generateSynthesis() {
    if (_selectedSession == null || _selectedSession!.responses.isEmpty) return;

    final synthesis = DebateSynthesis(
      id: const Uuid().v4(),
      content: 'Synthesis of responses from ${_selectedSession!.responses.length} models',
      generatedAt: DateTime.now(),
      consensusPoints: [
        'All models agree on the core approach',
        'Similar technical recommendations provided',
      ],
      differences: [
        'Model A emphasizes speed over accuracy',
        'Model B provides more detailed implementation',
      ],
      recommendation: 'Consider combining approaches from multiple models',
    );

    final updated = _selectedSession!.copyWith(
      synthesis: synthesis,
      status: DebateStatus.completed,
      updatedAt: DateTime.now(),
    );

    _updateSession(updated);
    notifyListeners();
  }

  /// Select a debate session.
  void selectSession(String sessionId) {
    _selectedSession = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => _sessions.first,
    );
    notifyListeners();
  }

  /// Delete a debate session.
  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_selectedSession?.id == sessionId) {
      _selectedSession = _sessions.isNotEmpty ? _sessions.first : null;
    }
    notifyListeners();
  }

  /// Toggle model availability.
  void toggleModel(String modelId) {
    final index = _availableModels.indexWhere((m) => m.id == modelId);
    if (index != -1) {
      final updated = _availableModels[index].copyWith(
        isEnabled: !_availableModels[index].isEnabled,
      );
      _availableModels[index] = updated;
      notifyListeners();
    }
  }

  void _updateSession(DebateSession updated) {
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _sessions[index] = updated;
      _selectedSession = updated;
    }
  }
}
