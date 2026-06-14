import '../../../core/services/storage_service.dart';
import '../../conversations/domain/models/conversation_item.dart';
import '../domain/models/message_model.dart';
import '../domain/models/message_role.dart';
import '../domain/models/routing_info.dart';
import 'chat_repository.dart';

class LocalChatRepository implements ChatRepository {
  LocalChatRepository(this._storage);

  final StorageService _storage;

  @override
  Future<List<ConversationItem>> loadConversations() async {
    final list = _storage.loadJsonList(StorageService.keyConversations);
    return list.map(ConversationItem.fromJson).toList();
  }

  @override
  Future<Map<String, List<MessageModel>>> loadAllMessages() async {
    final map = _storage.loadJsonMap(StorageService.keyMessages);
    if (map == null) return {};
    final result = <String, List<MessageModel>>{};
    for (final entry in map.entries) {
      final list = entry.value;
      if (list is List) {
        result[entry.key] = list
            .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    return result;
  }

  @override
  Future<void> saveConversations(List<ConversationItem> conversations) async {
    await _storage.saveJsonList(
      StorageService.keyConversations,
      conversations.map((c) => c.toJson()).toList(),
    );
  }

  @override
  Future<void> saveMessages(Map<String, List<MessageModel>> messagesByConversation) async {
    final encoded = <String, dynamic>{};
    for (final entry in messagesByConversation.entries) {
      encoded[entry.key] = entry.value.map((m) => m.toJson()).toList();
    }
    await _storage.saveJsonMap(StorageService.keyMessages, encoded);
  }

  @override
  Future<bool> isFirstLaunch() async {
    return !_storage.getBool(StorageService.keyInitialized);
  }

  @override
  Future<void> markInitialized() async {
    await _storage.setBool(StorageService.keyInitialized, true);
  }

  static List<ConversationItem> seedConversations() {
    final now = DateTime.now();
    return [
      ConversationItem(
        id: 'seed-1',
        title: 'Product roadmap draft',
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      ConversationItem(
        id: 'seed-2',
        title: 'Security audit checklist',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static Map<String, List<MessageModel>> seedMessages() {
    final now = DateTime.now();
    return {
      'seed-1': [
        MessageModel(
          id: 'm1',
          conversationId: 'seed-1',
          role: MessageRole.user,
          content: 'Help me outline a Q3 product roadmap for our AI platform.',
          createdAt: now.subtract(const Duration(hours: 2, minutes: 10)),
        ),
        MessageModel(
          id: 'm2',
          conversationId: 'seed-1',
          role: MessageRole.assistant,
          content: 'For your Q3 AI platform roadmap, I recommend:\n\n'
              '1. Finalize provider abstraction and routing policies.\n'
              '2. Ship enterprise auth and audit logging.\n'
              '3. Launch conversation analytics for operators.\n'
              '4. Run a security review before multi-tenant scale.\n\n'
              'Tell me your team size and top revenue goal to prioritize.',
          createdAt: now.subtract(const Duration(hours: 2, minutes: 9)),
          routing: const RoutingInfo(
            taskType: 'Research',
            selectedProvider: 'Google Gemini',
            executionStatus: 'Completed',
          ),
        ),
      ],
      'seed-2': [
        MessageModel(
          id: 'm3',
          conversationId: 'seed-2',
          role: MessageRole.user,
          content: 'Create a security audit checklist for our API.',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        MessageModel(
          id: 'm4',
          conversationId: 'seed-2',
          role: MessageRole.assistant,
          content: 'API security audit checklist:\n\n'
              '• Authentication and JWT rotation\n'
              '• Rate limiting on auth and chat endpoints\n'
              '• Input validation and SQL parameterization\n'
              '• CORS and helmet headers review\n'
              '• Secrets management and environment separation',
          createdAt: now.subtract(const Duration(days: 1, minutes: -1)),
          routing: const RoutingInfo(
            taskType: 'Code',
            selectedProvider: 'Aegis Code (Mock)',
            executionStatus: 'Completed',
          ),
        ),
      ],
    };
  }
}
