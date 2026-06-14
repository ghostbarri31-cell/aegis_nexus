import '../../conversations/domain/models/conversation_item.dart';
import '../domain/models/message_model.dart';

abstract class ChatRepository {
  Future<List<ConversationItem>> loadConversations();
  Future<Map<String, List<MessageModel>>> loadAllMessages();
  Future<void> saveConversations(List<ConversationItem> conversations);
  Future<void> saveMessages(Map<String, List<MessageModel>> messagesByConversation);
  Future<bool> isFirstLaunch();
  Future<void> markInitialized();
}
