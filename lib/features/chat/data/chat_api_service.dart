import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../conversations/domain/models/conversation_item.dart';
import '../domain/models/message_model.dart';
import '../domain/models/message_role.dart';
import '../domain/models/routing_info.dart';

class ChatApiService {
  ChatApiService(this._client);

  final ApiClient _client;

  Future<List<ConversationItem>> fetchConversations() async {
    final json = await _client.get('/chat/conversations', auth: true);
    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return ConversationItem(
        id: m['id'] as String,
        title: m['title'] as String? ?? 'Conversation',
        updatedAt: DateTime.parse(m['updatedAt'] as String),
        isArchived: m['isArchived'] as bool? ?? false,
      );
    }).toList();
  }

  Future<ConversationItem> createConversation({String? title}) async {
    final json = await _client.post('/chat/conversations', auth: true, body: {
      if (title != null) 'title': title,
    });
    final m = json['data'] as Map<String, dynamic>?;
    if (m == null) throw ApiException('Invalid conversation response');
    return ConversationItem(
      id: m['id'] as String,
      title: m['title'] as String? ?? 'New conversation',
      updatedAt: DateTime.parse(m['updatedAt'] as String),
    );
  }

  Future<List<MessageModel>> fetchMessages(String conversationId) async {
    final json = await _client.get('/chat/conversations/$conversationId/messages', auth: true);
    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) => _parseMessage(e as Map<String, dynamic>, conversationId)).toList();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    String? attachmentName,
  }) async {
    await _client.post(
      '/chat/conversations/$conversationId/messages',
      auth: true,
      body: {
        'content': content,
        'role': 'user',
        if (attachmentName != null) 'attachmentName': attachmentName,
      },
    );
  }

  MessageModel _parseMessage(Map<String, dynamic> m, String conversationId) {
    final metadata = m['metadata'] is Map
        ? Map<String, dynamic>.from(m['metadata'] as Map)
        : null;
    RoutingInfo? routing;
    if (metadata?['routing'] is Map) {
      routing = RoutingInfo.fromJson(
        Map<String, dynamic>.from(metadata!['routing'] as Map),
      );
    }

    return MessageModel(
      id: m['id'] as String,
      conversationId: conversationId,
      role: MessageRole.fromString(m['role'] as String? ?? 'user'),
      content: m['content'] as String? ?? '',
      createdAt: DateTime.parse(m['createdAt'] as String),
      attachmentName: metadata?['attachmentName'] as String?,
      routing: routing,
    );
  }
}
