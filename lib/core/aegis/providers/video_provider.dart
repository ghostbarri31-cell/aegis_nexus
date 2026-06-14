import '../domain/classification_result.dart';
import '../domain/provider_request.dart';
import '../domain/task_type.dart';
import 'base_mock_provider.dart';

class VideoProvider extends BaseMockProvider {
  @override
  String get id => 'aegis-video-mock';

  @override
  String get name => 'Aegis Video (Mock)';

  @override
  TaskType get taskType => TaskType.video;

  @override
  Duration get simulatedLatency => const Duration(milliseconds: 850);

  @override
  String buildContent(ProviderRequest request, ClassificationResult classification) {
    final file = request.attachmentName;
    final prompt = request.normalizedPrompt;
    return 'Video pipeline simulated.\n\n'
        '${file != null ? 'Source media: $file\n' : ''}'
        'Brief: "${prompt.isEmpty ? '(derived from upload)' : prompt}"\n\n'
        'Stages:\n'
        '• Storyboard keyframes\n'
        '• Scene generation / compositing\n'
        '• Audio sync (optional)\n'
        '• Export H.264 / WebM\n\n'
        'Mock job id: `aegis-video-job-${DateTime.now().millisecondsSinceEpoch}`\n'
        'Estimated render: 45s (mock)\n\n'
        'Plug in Runway, Pika, or a custom renderer through VideoProvider.';
  }
}
