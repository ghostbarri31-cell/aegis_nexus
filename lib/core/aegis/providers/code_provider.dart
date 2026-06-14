import '../domain/classification_result.dart';
import '../domain/provider_request.dart';
import '../domain/task_type.dart';
import 'base_mock_provider.dart';

class CodeProvider extends BaseMockProvider {
  @override
  String get id => 'aegis-code-mock';

  @override
  String get name => 'Aegis Code (Mock)';

  @override
  TaskType get taskType => TaskType.code;

  @override
  Duration get simulatedLatency => const Duration(milliseconds: 550);

  @override
  String buildContent(ProviderRequest request, ClassificationResult classification) {
    final prompt = request.normalizedPrompt;
    return 'Code analysis complete.\n\n'
        'Request: "$prompt"\n\n'
        'Recommended approach:\n'
        '1. Isolate the failing path or acceptance criteria.\n'
        '2. Add a minimal reproduction test.\n'
        '3. Implement the fix in small commits.\n'
        '4. Run static analysis and targeted tests.\n\n'
        '```dart\n'
        '// Example scaffold\n'
        'Future<void> runTask() async {\n'
        '  // Production code provider hooks in here\n'
        '}\n'
        '```\n\n'
        'Register a real CodeProvider to stream patches and diffs from your IDE agent.';
  }
}
