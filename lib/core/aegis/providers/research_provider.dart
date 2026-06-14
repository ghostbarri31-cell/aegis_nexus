import '../domain/classification_result.dart';
import '../domain/provider_request.dart';
import '../domain/task_type.dart';
import 'base_mock_provider.dart';

class ResearchProvider extends BaseMockProvider {
  @override
  String get id => 'aegis-research-mock';

  @override
  String get name => 'Aegis Research (Mock)';

  @override
  TaskType get taskType => TaskType.research;

  @override
  Duration get simulatedLatency => const Duration(milliseconds: 650);

  @override
  String buildContent(ProviderRequest request, ClassificationResult classification) {
    final prompt = request.normalizedPrompt;
    return 'Research synthesis complete.\n\n'
        'Topic: "$prompt"\n\n'
        'Findings (mock):\n'
        '1. Define scope and primary research questions.\n'
        '2. Gather sources (web, docs, internal KB).\n'
        '3. Cross-check claims and note confidence levels.\n'
        '4. Deliver executive summary + citations.\n\n'
        'Suggested sections: Overview · Evidence · Risks · Next steps\n\n'
        'Attach a live search/RAG backend by implementing ResearchProvider with your data sources.';
  }
}
