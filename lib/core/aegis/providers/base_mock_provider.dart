import '../domain/ai_provider.dart';
import '../domain/classification_result.dart';
import '../domain/execution_status.dart';
import '../domain/provider_request.dart';
import '../domain/provider_response.dart';

abstract class BaseMockProvider implements AIProvider {
  const BaseMockProvider();

  @override
  bool get isMock => true;

  Duration get simulatedLatency => const Duration(milliseconds: 450);

  @override
  Future<ProviderResponse> execute(
    ProviderRequest request, {
    required ClassificationResult classification,
  }) async {
    final started = DateTime.now();
    await Future<void>.delayed(simulatedLatency);
    final durationMs = DateTime.now().difference(started).inMilliseconds;

    return ProviderResponse(
      taskType: taskType,
      providerId: id,
      providerName: name,
      executionStatus: ExecutionStatus.completed,
      content: buildContent(request, classification),
      durationMs: durationMs,
    );
  }

  String buildContent(ProviderRequest request, ClassificationResult classification);
}
