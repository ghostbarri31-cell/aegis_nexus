import { TaskType } from '../task-types.js';
import { BaseMockProvider } from './base-mock-provider.js';

export class ResearchProvider extends BaseMockProvider {
  constructor() {
    super({
      id: 'aegis-research-mock',
      name: 'Aegis Research (Mock)',
      taskType: TaskType.RESEARCH,
      latencyMs: 650,
    });
  }

  buildContent(request) {
    return `Research synthesis complete for: "${request.prompt}"`;
  }
}
