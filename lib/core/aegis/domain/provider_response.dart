import 'execution_status.dart';
import 'task_type.dart';

class ProviderResponse {
  const ProviderResponse({
    required this.taskType,
    required this.providerId,
    required this.providerName,
    required this.executionStatus,
    required this.content,
    this.errorMessage,
    this.durationMs,
  });

  final TaskType taskType;
  final String providerId;
  final String providerName;
  final ExecutionStatus executionStatus;
  final String content;
  final String? errorMessage;
  final int? durationMs;

  bool get isSuccess => executionStatus == ExecutionStatus.completed;
}
