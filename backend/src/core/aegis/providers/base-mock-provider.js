import { ExecutionStatus } from '../task-types.js';

export class BaseMockProvider {
  constructor({ id, name, taskType, latencyMs = 450 }) {
    this.id = id;
    this.name = name;
    this.taskType = taskType;
    this.latencyMs = latencyMs;
    this.isMock = true;
  }

  async execute(request, classification) {
    await new Promise((r) => setTimeout(r, this.latencyMs));
    return {
      taskType: this.taskType,
      providerId: this.id,
      providerName: this.name,
      executionStatus: ExecutionStatus.COMPLETED,
      content: this.buildContent(request, classification),
      isMock: true,
    };
  }

  buildContent(_request, _classification) {
    throw new Error('buildContent must be implemented');
  }
}
