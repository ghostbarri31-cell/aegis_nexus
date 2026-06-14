import '../domain/execution_status.dart';
import '../domain/provider_request.dart';
import '../domain/provider_response.dart';
import '../domain/routing_info.dart';
import 'provider_registry.dart';
import 'task_classifier.dart';

typedef RoutingProgressCallback = void Function(RoutingInfo info);

class RouterService {
  RouterService({
    TaskClassifier? classifier,
    ProviderRegistry? registry,
  })  : _classifier = classifier ?? const TaskClassifier(),
        _registry = registry ?? ProviderRegistry();

  final TaskClassifier _classifier;
  final ProviderRegistry _registry;

  ProviderRegistry get registry => _registry;

  Future<ProviderResponse> route(
    ProviderRequest request, {
    RoutingProgressCallback? onProgress,
  }) async {
    onProgress?.call(
      const RoutingInfo(
        taskType: '—',
        selectedProvider: '—',
        executionStatus: 'Classifying',
      ),
    );

    final classification = _classifier.classify(request);
    final provider = _registry.resolve(classification.taskType);

    onProgress?.call(
      RoutingInfo(
        taskType: classification.taskType.displayLabel,
        selectedProvider: provider.name,
        executionStatus: ExecutionStatus.routing.label,
        confidence: classification.confidence,
      ),
    );

    onProgress?.call(
      RoutingInfo(
        taskType: classification.taskType.displayLabel,
        selectedProvider: provider.name,
        executionStatus: ExecutionStatus.executing.label,
        confidence: classification.confidence,
      ),
    );

    try {
      final response = await provider.execute(
        request,
        classification: classification,
      );

      onProgress?.call(
        RoutingInfo(
          taskType: response.taskType.displayLabel,
          selectedProvider: response.providerName,
          executionStatus: ExecutionStatus.completed.label,
          confidence: classification.confidence,
        ),
      );

      return response;
    } catch (e) {
      onProgress?.call(
        RoutingInfo(
          taskType: classification.taskType.displayLabel,
          selectedProvider: provider.name,
          executionStatus: ExecutionStatus.failed.label,
          confidence: classification.confidence,
        ),
      );

      return ProviderResponse(
        taskType: classification.taskType,
        providerId: provider.id,
        providerName: provider.name,
        executionStatus: ExecutionStatus.failed,
        content: 'Execution failed: $e',
        errorMessage: e.toString(),
      );
    }
  }

  List<Map<String, dynamic>> listProviders() {
    return _registry.all
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'taskType': p.taskType.value,
            'isMock': p.isMock,
          },
        )
        .toList();
  }
}
