import 'task_type.dart';

class ClassificationResult {
  const ClassificationResult({
    required this.taskType,
    required this.confidence,
    this.signals = const [],
  });

  final TaskType taskType;
  final double confidence;
  final List<String> signals;
}
