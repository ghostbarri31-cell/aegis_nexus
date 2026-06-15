import { TaskType } from './task-types.js';

const IMAGE_EXT = ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg'];
const VIDEO_EXT = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];

const TEXT_MARGIN = 0.10;

function matchesWord(text, word) {
  const escaped = word.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  return new RegExp(`(?<![\\p{L}\\p{N}])${escaped}(?![\\p{L}\\p{N}])`, 'iu').test(text);
}

function scoreKeywords(text, keys, base, perHit) {
  let hits = 0;
  for (const key of keys) {
    if (matchesWord(text, key)) hits += 1;
  }
  return base + hits * perHit;
}

export class TaskClassifier {
  classify({ prompt = '', attachmentName = '' }) {
    const text = String(prompt).toLowerCase();
    const attachment = String(attachmentName).toLowerCase();
    const combined = `${text} ${attachment}`;

    const scores = {
      [TaskType.TEXT]: 0.35,
      [TaskType.CODE]: scoreKeywords(combined, [
        'code', 'function', 'api', 'bug', 'debug', 'flutter', 'dart',
        'python', 'javascript', 'typescript', 'sql', 'refactor', 'syntax',
        'corrige', 'programme', 'node', 'script', 'développe',
      ], 0.15, 0.2),
      [TaskType.IMAGE]: IMAGE_EXT.some((ext) => attachment.endsWith(ext))
        ? 0.95
        : scoreKeywords(combined, [
            'image', 'picture', 'photo', 'illustration', 'draw', 'logo', 'icon',
            'dessine', 'dessin',
          ], 0.1, 0.4),
      [TaskType.VIDEO]: VIDEO_EXT.some((ext) => attachment.endsWith(ext))
        ? 0.95
        : scoreKeywords(combined, [
            'video', 'clip', 'animation', 'motion', 'film', 'footage', 'mp4',
            'vidéo',
          ], 0.1, 0.4),
      [TaskType.RESEARCH]: scoreKeywords(combined, [
        'research', 'study', 'analyze', 'report', 'survey', 'paper', 'sources',
        'market', 'competitor', 'benchmark', 'investigate',
        'recherche', 'étude', 'analyse', 'concurrence', 'concurrent', 'marché', 'enquête',
      ], 0.12, 0.2),
    };

    const textScore = scores[TaskType.TEXT];
    const threshold = textScore + TEXT_MARGIN;

    let best = TaskType.TEXT;
    let bestScore = textScore;

    for (const [type, value] of Object.entries(scores)) {
      if (type === TaskType.TEXT) continue;
      if (value > threshold && value > bestScore) {
        bestScore = value;
        best = type;
      }
    }

    return {
      taskType: best,
      confidence: Math.round(Math.min(Math.max(bestScore, 0.35), 1) * 100) / 100,
      signals: [`task:${best}`],
    };
  }
}
