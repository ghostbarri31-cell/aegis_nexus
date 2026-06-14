import '../clients/gemini_api_client.dart';
import '../clients/gemini_exceptions.dart';
import '../domain/ai_provider.dart';
import '../domain/classification_result.dart';
import '../domain/execution_status.dart';
import '../domain/provider_request.dart';
import '../domain/provider_response.dart';
import '../domain/task_type.dart';

class GeminiProvider implements AIProvider {
  GeminiProvider({GeminiApiClient? client}) : _client = client ?? GeminiApiClient();

  final GeminiApiClient _client;

  @override
  String get id => 'aegis-gemini';

  @override
  String get name => 'Google Gemini';

  @override
  TaskType get taskType => TaskType.text;

  @override
  bool get isMock => false;

  @override
  Future<ProviderResponse> execute(
    ProviderRequest request, {
    required ClassificationResult classification,
  }) async {
    final started = DateTime.now();
    final prompt = _buildPrompt(request);

    try {
      final content = await _client.generateWithRetry(prompt);
      return ProviderResponse(
        taskType: taskType,
        providerId: id,
        providerName: name,
        executionStatus: ExecutionStatus.completed,
        content: content,
        durationMs: DateTime.now().difference(started).inMilliseconds,
      );
    } on GeminiAuthException catch (e) {
      return _failed(e.message, started);
    } on GeminiTimeoutException catch (e) {
      return _failed(e.message, started);
    } on GeminiException catch (e) {
      return _failed(e.message, started);
    } catch (e) {
      return _failed('Unexpected Gemini error: $e', started);
    }
  }

  String _buildPrompt(ProviderRequest request) {
    final base = request.normalizedPrompt;
    if (request.attachmentName != null && base.isEmpty) {
      return 'The user attached a file named "${request.attachmentName}". '
          'Explain how you would help process it.';
    }
    if (request.attachmentName != null) {
      return '$base\n\n[Attached file: ${request.attachmentName}]';
    }
    return base;
  }

  ProviderResponse _failed(String message, DateTime started) {
    return ProviderResponse(
      taskType: taskType,
      providerId: id,
      providerName: name,
      executionStatus: ExecutionStatus.failed,
      content: message,
      errorMessage: message,
      durationMs: DateTime.now().difference(started).inMilliseconds,
    );
  }
}
