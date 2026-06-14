import 'package:aegis_nexus/core/aegis/clients/gemini_api_client.dart';
import 'package:aegis_nexus/core/aegis/domain/execution_status.dart';
import 'package:aegis_nexus/core/aegis/domain/provider_request.dart';
import 'package:aegis_nexus/core/aegis/providers/code_provider.dart';
import 'package:aegis_nexus/core/aegis/providers/gemini_provider.dart';
import 'package:aegis_nexus/core/aegis/providers/image_provider.dart';
import 'package:aegis_nexus/core/aegis/providers/research_provider.dart';
import 'package:aegis_nexus/core/aegis/providers/video_provider.dart';
import 'package:aegis_nexus/core/aegis/routing/provider_registry.dart';
import 'package:aegis_nexus/core/aegis/routing/router_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGeminiClient extends GeminiApiClient {
  _FakeGeminiClient() : super(apiKey: 'test-key');

  @override
  Future<String> generateWithRetry(String prompt) async => 'Gemini reply: $prompt';
}

void main() {
  test('routes text through Gemini provider', () async {
    final router = RouterService(
      registry: ProviderRegistry(
        providers: [
          GeminiProvider(client: _FakeGeminiClient()),
          CodeProvider(),
          ImageProvider(),
          VideoProvider(),
          ResearchProvider(),
        ],
      ),
    );

    final progress = <String>[];

    final response = await router.route(
      const ProviderRequest(prompt: 'Bonjour'),
      onProgress: (info) => progress.add(info.executionStatus),
    );

    expect(response.executionStatus, ExecutionStatus.completed);
    expect(response.content, contains('Gemini reply'));
    expect(response.providerName, 'Google Gemini');
    expect(progress, contains('Completed'));
  });
}
