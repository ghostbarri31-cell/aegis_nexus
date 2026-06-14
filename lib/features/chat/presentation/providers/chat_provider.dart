import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/aegis/domain/provider_request.dart';
import '../../../../core/aegis/domain/routing_info.dart';
import '../../../../core/aegis/routing/router_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../conversations/domain/models/conversation_item.dart';
import '../../data/chat_api_service.dart';
import '../../data/chat_repository.dart';
import '../../data/local_chat_repository.dart';
import '../../domain/models/message_model.dart';
import '../../domain/models/message_role.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(
    this._repository, {
    required RouterService router,
    ChatApiService? chatApi,
    ApiClient? apiClient,
    Uuid? uuid,
  })  : _router = router,
        _chatApi = chatApi,
        _apiClient = apiClient,
        _uuid = uuid ?? const Uuid();

  final ChatRepository _repository;
  final RouterService _router;
  ChatApiService? _chatApi;
  ApiClient? _apiClient;
  final Uuid _uuid;

  List<ConversationItem> _conversations = [];
  Map<String, List<MessageModel>> _messages = {};
  String? _selectedId;
  bool _loading = true;
  bool _sending = false;
  String? _syncError;

  List<ConversationItem> get conversations =>
      List.unmodifiable(_conversations.where((c) => !c.isArchived));

  String? get selectedId => _selectedId;
  bool get isLoading => _loading;
  bool get isSending => _sending;
  String? get syncError => _syncError;
  RouterService get router => _router;

  ConversationItem? get selected {
    if (_selectedId == null) return null;
    try {
      return _conversations.firstWhere((c) => c.id == _selectedId);
    } catch (_) {
      return null;
    }
  }

  List<MessageModel> get selectedMessages {
    final id = _selectedId;
    if (id == null) return const [];
    return List.unmodifiable(_messages[id] ?? []);
  }

  bool get hasMessagesInSelected => selectedMessages.isNotEmpty;

  bool get _useApi =>
      _chatApi != null && _apiClient != null && _apiClient!.hasToken;

  void updateApi(ChatApiService? chatApi, ApiClient? apiClient) {
    _chatApi = chatApi;
    _apiClient = apiClient;
  }

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    if (_useApi) {
      try {
        await syncFromRemote();
        _loading = false;
        notifyListeners();
        return;
      } catch (e) {
        _syncError = e.toString();
      }
    }

    final firstLaunch = await _repository.isFirstLaunch();
    if (firstLaunch) {
      _conversations = LocalChatRepository.seedConversations();
      _messages = LocalChatRepository.seedMessages();
      _selectedId = _conversations.first.id;
      await _persist();
      await _repository.markInitialized();
    } else {
      _conversations = await _repository.loadConversations();
      _messages = await _repository.loadAllMessages();
      _selectedId = _conversations.isNotEmpty ? _conversations.first.id : null;
    }

    _conversations = _applyActiveFlag(_selectedId);
    _loading = false;
    notifyListeners();
  }

  Future<void> syncFromRemote() async {
    if (!_useApi) return;
    final api = _chatApi!;
    _syncError = null;
    final remoteConversations = await api.fetchConversations();
    _conversations = remoteConversations;
    _messages = {};
    for (final c in remoteConversations) {
      _messages[c.id] = await api.fetchMessages(c.id);
    }
    _selectedId = _conversations.isNotEmpty ? _conversations.first.id : null;
    _conversations = _applyActiveFlag(_selectedId);
    await _persist();
    await _repository.markInitialized();
    notifyListeners();
  }

  List<ConversationItem> _applyActiveFlag(String? activeId) {
    return _conversations
        .map((c) => c.copyWith(isActive: c.id == activeId))
        .toList();
  }

  void select(String id) {
    _selectedId = id;
    _conversations = _applyActiveFlag(id);
    notifyListeners();
  }

  Future<void> createNew() async {
    if (_useApi) {
      final remote = await _chatApi!.createConversation();
      _conversations = [
        remote.copyWith(isActive: true),
        ..._conversations.map((c) => c.copyWith(isActive: false)),
      ];
      _messages[remote.id] = [];
      _selectedId = remote.id;
      await _persist();
      notifyListeners();
      return;
    }

    final id = _uuid.v4();
    final item = ConversationItem(
      id: id,
      title: 'New conversation',
      updatedAt: DateTime.now(),
      isActive: true,
    );
    _conversations = [item, ..._conversations.map((c) => c.copyWith(isActive: false))];
    _messages[id] = [];
    _selectedId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    _conversations = _conversations.where((c) => c.id != id).toList();
    _messages.remove(id);
    if (_selectedId == id) {
      _selectedId = _conversations.isNotEmpty ? _conversations.first.id : null;
      _conversations = _applyActiveFlag(_selectedId);
    }
    if (_conversations.isEmpty) {
      await createNew();
      return;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> sendMessage({
    required String text,
    String? attachmentName,
  }) async {
    var conversationId = _selectedId;
    if (conversationId == null) {
      await createNew();
      conversationId = _selectedId;
    }
    if (conversationId == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty && attachmentName == null) return;

    _sending = true;
    notifyListeners();

    final content = trimmed.isEmpty ? 'Attached file: $attachmentName' : trimmed;

    if (_useApi) {
      try {
        await _chatApi!.sendMessage(
          conversationId: conversationId,
          content: content,
          attachmentName: attachmentName,
        );
        _messages[conversationId] = await _chatApi!.fetchMessages(conversationId);
        final idx = _conversations.indexWhere((c) => c.id == conversationId);
        if (idx >= 0 && trimmed.isNotEmpty) {
          var conv = _conversations[idx];
          if (conv.title == 'New conversation') {
            conv = conv.copyWith(title: _titleFromMessage(trimmed));
          }
          _conversations[idx] = conv.copyWith(updatedAt: DateTime.now());
          _conversations = _sortConversations(_conversations);
        }
        _sending = false;
        await _persist();
        notifyListeners();
        return;
      } catch (e) {
        _syncError = e.toString();
      }
    }

    final now = DateTime.now();
    final userMessage = MessageModel(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: now,
      attachmentName: attachmentName,
    );

    final list = List<MessageModel>.from(_messages[conversationId] ?? [])..add(userMessage);
    _messages[conversationId] = list;

    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex >= 0) {
      var conv = _conversations[convIndex];
      if (conv.title == 'New conversation' && trimmed.isNotEmpty) {
        conv = conv.copyWith(title: _titleFromMessage(trimmed));
      }
      _conversations[convIndex] = conv.copyWith(updatedAt: now);
      _conversations = _sortConversations(_conversations);
    }

    final assistantId = _uuid.v4();
    var assistantMessage = MessageModel(
      id: assistantId,
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      routing: const RoutingInfo(
        taskType: '—',
        selectedProvider: '—',
        executionStatus: 'Classifying',
      ),
    );

    _messages[conversationId] = List<MessageModel>.from(_messages[conversationId]!)
      ..add(assistantMessage);
    notifyListeners();

    final request = ProviderRequest(
      prompt: trimmed.isEmpty ? content : trimmed,
      attachmentName: attachmentName,
      conversationId: conversationId,
      messageId: userMessage.id,
    );

    final response = await _router.route(
      request,
      onProgress: (info) {
        final messages = _messages[conversationId];
        if (messages == null) return;
        final index = messages.indexWhere((m) => m.id == assistantId);
        if (index < 0) return;
        messages[index] = messages[index].copyWith(routing: info);
        notifyListeners();
      },
    );

    final finalRouting = RoutingInfo(
      taskType: response.taskType.displayLabel,
      selectedProvider: response.providerName,
      executionStatus: response.executionStatus.label,
    );

    final messages = _messages[conversationId]!;
    final index = messages.indexWhere((m) => m.id == assistantId);
    if (index >= 0) {
      messages[index] = messages[index].copyWith(
        content: response.content,
        routing: finalRouting,
      );
    }

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx >= 0) {
      _conversations[idx] = _conversations[idx].copyWith(updatedAt: DateTime.now());
      _conversations = _sortConversations(_conversations);
    }

    _sending = false;
    await _persist();
    notifyListeners();
  }

  String _titleFromMessage(String text) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.length <= 48) return clean;
    return '${clean.substring(0, 45)}…';
  }

  List<ConversationItem> _sortConversations(List<ConversationItem> items) {
    final sorted = List<ConversationItem>.from(items)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.map((c) => c.copyWith(isActive: c.id == _selectedId)).toList();
  }

  Future<void> _persist() async {
    await _repository.saveConversations(
      _conversations.map((c) => c.copyWith(isActive: false)).toList(),
    );
    await _repository.saveMessages(_messages);
  }
}
