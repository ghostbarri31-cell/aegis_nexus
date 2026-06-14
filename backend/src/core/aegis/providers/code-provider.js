import { TaskType } from '../task-types.js';
import { BaseMockProvider } from './base-mock-provider.js';

export class CodeProvider extends BaseMockProvider {
  constructor() {
    super({
      id: 'aegis-code-mock',
      name: 'Aegis Code (Mock)',
      taskType: TaskType.CODE,
      latencyMs: 550,
    });
  }

  buildContent(request) {
    return `Code analysis complete for: "${request.prompt}"`;
  }
}
