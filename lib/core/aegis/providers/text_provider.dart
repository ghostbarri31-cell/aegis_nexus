import '../domain/classification_result.dart';
import '../domain/provider_request.dart';
import '../domain/task_type.dart';
import 'base_mock_provider.dart';

class TextProvider extends BaseMockProvider {
  @override
  String get id => 'aegis-text-mock';

  @override
  String get name => 'Aegis Text (Mock)';

  @override
  TaskType get taskType => TaskType.text;

  @override
  String buildContent(ProviderRequest request, ClassificationResult classification) {
    final prompt = request.normalizedPrompt;
    if (prompt.isEmpty && request.attachmentName != null) {
      return 'Text provider ready to process "${request.attachmentName}". '
          'Describe the writing task you need (tone, length, audience).';
    }
    return 'Text processing complete.\n\n'
        'I prepared a clear written response for:\n"$prompt"\n\n'
        '• Structure: introduction, key points, conclusion\n'
        '• Tone: professional and direct\n'
        '• Confidence: ${(classification.confidence * 100).toStringAsFixed(0)}%\n\n'
        'Swap this mock with a live LLM API by registering a production TextProvider.';
  }
}
