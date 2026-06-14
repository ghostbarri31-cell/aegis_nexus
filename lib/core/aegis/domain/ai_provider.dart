import 'classification_result.dart';
import 'provider_request.dart';
import 'provider_response.dart';
import 'task_type.dart';

abstract class AIProvider {
  String get id;
  String get name;
  TaskType get taskType;
  bool get isMock;

  Future<ProviderResponse> execute(
    ProviderRequest request, {
    required ClassificationResult classification,
  });
}
