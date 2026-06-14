import { TaskType } from '../task-types.js';
import { BaseMockProvider } from './base-mock-provider.js';

export class ImageProvider extends BaseMockProvider {
  constructor() {
    super({
      id: 'aegis-image-mock',
      name: 'Aegis Image (Mock)',
      taskType: TaskType.IMAGE,
      latencyMs: 700,
    });
  }

  buildContent(request) {
    return `Image pipeline simulated for: "${request.prompt}"`;
  }
}
