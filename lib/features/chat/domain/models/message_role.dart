enum MessageRole {
  user,
  assistant,
  system;

  String get storageValue => name;

  static MessageRole fromString(String value) {
    return MessageRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => MessageRole.user,
    );
  }
}
