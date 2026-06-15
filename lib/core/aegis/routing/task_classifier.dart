import '../domain/classification_result.dart';
import '../domain/provider_request.dart';
import '../domain/task_type.dart';

class TaskClassifier {
  const TaskClassifier();

  static const _textMargin = 0.10;

  static final _imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg'];
  static final _videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];

  ClassificationResult classify(ProviderRequest request) {
    final text = request.normalizedPrompt.toLowerCase();
    final attachment = request.attachmentName?.toLowerCase() ?? '';
    final combined = '$text $attachment';

    final scores = <TaskType, double>{
      TaskType.text: 0.35,
      TaskType.code: _scoreCode(combined),
      TaskType.image: _scoreImage(combined, attachment),
      TaskType.video: _scoreVideo(combined, attachment),
      TaskType.research: _scoreResearch(combined),
    };

    final textScore = scores[TaskType.text]!;
    final threshold = textScore + _textMargin;

    var best = TaskType.text;
    var bestScore = textScore;

    for (final entry in scores.entries) {
      if (entry.key == TaskType.text) continue;
      if (entry.value > threshold && entry.value > bestScore) {
        bestScore = entry.value;
        best = entry.key;
      }
    }

    final signals = _collectSignals(best, combined);
    final confidence = (bestScore.clamp(0.35, 1.0) * 100).round() / 100;

    return ClassificationResult(
      taskType: best,
      confidence: confidence,
      signals: signals,
    );
  }

  static bool _matchesWord(String text, String word) {
    final escaped = RegExp.escape(word.trim());
    return RegExp('(?<![\\p{L}\\p{N}])$escaped(?![\\p{L}\\p{N}])', caseSensitive: false, unicode: true).hasMatch(text);
  }

  double _scoreCode(String text) {
    const keys = [
      'code', 'function', 'class', 'api', 'bug', 'debug', 'flutter',
      'dart', 'python', 'javascript', 'typescript', 'sql', 'refactor',
      'compile', 'syntax', 'github', 'repository', 'npm', 'docker',
      'corrige', 'programme', 'node', 'script', 'développe',
    ];
    return _keywordScore(text, keys, base: 0.15, perHit: 0.2);
  }

  double _scoreImage(String text, String attachment) {
    if (_imageExtensions.any(attachment.endsWith)) return 0.95;
    const keys = [
      'image', 'picture', 'photo', 'illustration', 'draw', 'render',
      'logo', 'icon', 'banner', 'thumbnail', 'png', 'jpeg',
      'dessine', 'dessin',
    ];
    return _keywordScore(text, keys, base: 0.1, perHit: 0.4);
  }

  double _scoreVideo(String text, String attachment) {
    if (_videoExtensions.any(attachment.endsWith)) return 0.95;
    const keys = [
      'video', 'clip', 'animation', 'motion', 'film', 'footage',
      'storyboard', 'mp4', 'edit video', 'render video',
      'vidéo',
    ];
    return _keywordScore(text, keys, base: 0.1, perHit: 0.4);
  }

  double _scoreResearch(String text) {
    const keys = [
      'research', 'study', 'analyze', 'analysis', 'compare', 'report',
      'survey', 'literature', 'paper', 'sources', 'citations',
      'market', 'competitor', 'benchmark', 'whitepaper', 'investigate',
      'recherche', 'étude', 'analyse', 'concurrence', 'concurrent', 'marché', 'enquête',
    ];
    return _keywordScore(text, keys, base: 0.12, perHit: 0.2);
  }

  double _keywordScore(
    String text,
    List<String> keys, {
    required double base,
    required double perHit,
  }) {
    var hits = 0;
    for (final key in keys) {
      if (_matchesWord(text, key)) hits++;
    }
    return base + (hits * perHit);
  }

  List<String> _collectSignals(TaskType type, String text) {
    final signals = <String>['task:${type.value}'];
    if (text.contains('?')) signals.add('question_detected');
    if (text.length > 120) signals.add('long_form');
    if (text.split(RegExp(r'\s+')).length > 25) signals.add('multi_sentence');
    return signals;
  }
}
