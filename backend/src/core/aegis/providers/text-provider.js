import { TaskType } from '../task-types.js';
import { BaseMockProvider } from './base-mock-provider.js';

export class TextProvider extends BaseMockProvider {
  constructor() {
    super({ id: 'aegis-text-mock', name: 'Aegis Text (Mock)', taskType: TaskType.TEXT });
  }

  buildContent(request, classification) {
    const prompt = String(request.prompt || '').trim();
    return `Text processing complete.\n\n"${prompt}"\n\nConfidence: ${classification.confidence}`;
  }
}
