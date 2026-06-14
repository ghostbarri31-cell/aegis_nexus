import 'routing_info.dart';
import 'message_role.dart';

class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.attachmentName,
    this.routing,
  });

  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final String? attachmentName;
  final RoutingInfo? routing;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  MessageModel copyWith({
    String? content,
    String? attachmentName,
    RoutingInfo? routing,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      role: role,
      content: content ?? this.content,
      createdAt: createdAt,
      attachmentName: attachmentName ?? this.attachmentName,
      routing: routing ?? this.routing,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'role': role.storageValue,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'attachmentName': attachmentName,
        if (routing != null) 'routing': routing!.toJson(),
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: MessageRole.fromString(json['role'] as String? ?? 'user'),
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      attachmentName: json['attachmentName'] as String?,
      routing: json['routing'] is Map
          ? RoutingInfo.fromJson(Map<String, dynamic>.from(json['routing'] as Map))
          : null,
    );
  }
}
