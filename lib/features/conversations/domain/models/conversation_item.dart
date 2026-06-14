class ConversationItem {
  const ConversationItem({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.isActive = false,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final DateTime updatedAt;
  final bool isActive;
  final bool isArchived;

  ConversationItem copyWith({
    bool? isActive,
    String? title,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return ConversationItem(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updatedAt': updatedAt.toIso8601String(),
        'isArchived': isArchived,
      };

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    return ConversationItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Conversation',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}
