import '../domain/ai_provider.dart';
import '../domain/task_type.dart';
import '../providers/code_provider.dart';
import '../providers/image_provider.dart';
import '../providers/research_provider.dart';
import '../providers/gemini_provider.dart';
import '../providers/video_provider.dart';

class ProviderRegistry {
  ProviderRegistry({List<AIProvider>? providers})
      : _byType = {
          for (final p in providers ?? _defaultProviders) p.taskType: p,
        },
        _byId = {
          for (final p in providers ?? _defaultProviders) p.id: p,
        };

  static final List<AIProvider> _defaultProviders = [
    GeminiProvider(),
    CodeProvider(),
    ImageProvider(),
    VideoProvider(),
    ResearchProvider(),
  ];

  final Map<TaskType, AIProvider> _byType;
  final Map<String, AIProvider> _byId;

  List<AIProvider> get all => List.unmodifiable(_byType.values);

  AIProvider resolve(TaskType taskType) {
    return _byType[taskType] ?? _byType[TaskType.text]!;
  }

  AIProvider? findById(String id) => _byId[id];

  void register(AIProvider provider) {
    _byType[provider.taskType] = provider;
    _byId[provider.id] = provider;
  }

  void unregister(String providerId) {
    final provider = _byId.remove(providerId);
    if (provider != null) {
      _byType.remove(provider.taskType);
    }
  }
}
