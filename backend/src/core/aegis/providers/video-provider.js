import { TaskType } from '../task-types.js';
import { BaseMockProvider } from './base-mock-provider.js';

export class VideoProvider extends BaseMockProvider {
  constructor() {
    super({
      id: 'aegis-video-mock',
      name: 'Aegis Video (Mock)',
      taskType: TaskType.VIDEO,
      latencyMs: 850,
    });
  }

  buildContent(request) {
    return `Video pipeline simulated for: "${request.prompt}"`;
  }
}
