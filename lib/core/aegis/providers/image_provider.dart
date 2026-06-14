import '../domain/classification_result.dart';
import '../domain/provider_request.dart';
import '../domain/task_type.dart';
import 'base_mock_provider.dart';

class ImageProvider extends BaseMockProvider {
  @override
  String get id => 'aegis-image-mock';

  @override
  String get name => 'Aegis Image (Mock)';

  @override
  TaskType get taskType => TaskType.image;

  @override
  Duration get simulatedLatency => const Duration(milliseconds: 700);

  @override
  String buildContent(ProviderRequest request, ClassificationResult classification) {
    final file = request.attachmentName;
    final prompt = request.normalizedPrompt;
    return 'Image pipeline simulated.\n\n'
        '${file != null ? 'Input file: $file\n' : ''}'
        'Prompt: "${prompt.isEmpty ? '(style from attachment)' : prompt}"\n\n'
        'Pipeline steps:\n'
        '• Parse dimensions and format\n'
        '• Apply style and composition rules\n'
        '• Generate asset + safety filter\n'
        '• Return URL or bytes to the client\n\n'
        'Mock output: `aegis://assets/generated/${DateTime.now().millisecondsSinceEpoch}.png`\n\n'
        'Connect DALL·E, Stable Diffusion, or Imagen via a production ImageProvider.';
  }
}
