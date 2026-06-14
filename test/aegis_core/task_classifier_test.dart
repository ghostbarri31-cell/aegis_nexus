import 'package:aegis_nexus/core/aegis/domain/provider_request.dart';
import 'package:aegis_nexus/core/aegis/domain/task_type.dart';
import 'package:aegis_nexus/core/aegis/routing/task_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const classifier = TaskClassifier();

  test('classifies code requests', () {
    final result = classifier.classify(
      const ProviderRequest(prompt: 'Fix the Flutter API bug in my repository'),
    );
    expect(result.taskType, TaskType.code);
  });

  test('classifies image requests', () {
    final result = classifier.classify(
      const ProviderRequest(prompt: 'Generate a logo image for our brand'),
    );
    expect(result.taskType, TaskType.image);
  });

  test('classifies video requests', () {
    final result = classifier.classify(
      const ProviderRequest(prompt: 'Create a short product demo video'),
    );
    expect(result.taskType, TaskType.video);
  });

  test('classifies research requests', () {
    final result = classifier.classify(
      const ProviderRequest(prompt: 'Research competitors and write a market report'),
    );
    expect(result.taskType, TaskType.research);
  });

  test('classifies attachment as image', () {
    final result = classifier.classify(
      const ProviderRequest(
        prompt: 'Enhance this',
        attachmentName: 'photo.png',
      ),
    );
    expect(result.taskType, TaskType.image);
  });
}
