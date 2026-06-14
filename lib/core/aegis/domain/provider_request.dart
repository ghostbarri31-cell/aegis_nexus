class ProviderRequest {
  const ProviderRequest({
    required this.prompt,
    this.attachmentName,
    this.conversationId,
    this.messageId,
  });

  final String prompt;
  final String? attachmentName;
  final String? conversationId;
  final String? messageId;

  String get normalizedPrompt => prompt.trim();
}
