import { ExecutionStatus, TaskType } from './task-types.js';
import { TaskClassifier } from './task-classifier.js';
import { ProviderRegistry } from './provider-registry.js';

const TASK_LABELS = {
  [TaskType.TEXT]: 'Text',
  [TaskType.CODE]: 'Code',
  [TaskType.IMAGE]: 'Image',
  [TaskType.VIDEO]: 'Video',
  [TaskType.RESEARCH]: 'Research',
};

export class RouterService {
  constructor({ classifier, registry } = {}) {
    this._classifier = classifier ?? new TaskClassifier();
    this._registry = registry ?? new ProviderRegistry();
  }

  get registry() {
    return this._registry;
  }

  listProviders() {
    return this._registry.list().map((p) => ({
      id: p.id,
      name: p.name,
      taskType: p.taskType,
      isMock: p.isMock,
    }));
  }

  async route(request, onProgress) {
    onProgress?.({
      taskType: '—',
      selectedProvider: '—',
      executionStatus: ExecutionStatus.CLASSIFYING,
    });

    const classification = this._classifier.classify(request);
    const provider = this._registry.resolve(classification.taskType);
    const taskLabel = TASK_LABELS[classification.taskType] ?? classification.taskType;

    onProgress?.({
      taskType: taskLabel,
      selectedProvider: provider.name,
      executionStatus: ExecutionStatus.ROUTING,
      confidence: classification.confidence,
    });

    onProgress?.({
      taskType: taskLabel,
      selectedProvider: provider.name,
      executionStatus: ExecutionStatus.EXECUTING,
      confidence: classification.confidence,
    });

    try {
      const result = await provider.execute(request, classification);

      onProgress?.({
        taskType: TASK_LABELS[result.taskType] ?? result.taskType,
        selectedProvider: result.providerName,
        executionStatus: ExecutionStatus.COMPLETED,
        confidence: classification.confidence,
      });

      return {
        ...result,
        routing: {
          taskType: TASK_LABELS[result.taskType] ?? result.taskType,
          selectedProvider: result.providerName,
          executionStatus: ExecutionStatus.COMPLETED,
          confidence: classification.confidence,
        },
        classification,
      };
    } catch (err) {
      onProgress?.({
        taskType: taskLabel,
        selectedProvider: provider.name,
        executionStatus: ExecutionStatus.FAILED,
        confidence: classification.confidence,
      });

      return {
        taskType: classification.taskType,
        providerId: provider.id,
        providerName: provider.name,
        executionStatus: ExecutionStatus.FAILED,
        content: `Execution failed: ${err.message}`,
        errorMessage: err.message,
        routing: {
          taskType: taskLabel,
          selectedProvider: provider.name,
          executionStatus: ExecutionStatus.FAILED,
          confidence: classification.confidence,
        },
        classification,
      };
    }
  }
}
