import { TaskType } from './task-types.js';
import { GroqProvider } from './providers/groq-provider.js';
import { CodeProvider } from './providers/code-provider.js';
import { ImageProvider } from './providers/image-provider.js';
import { VideoProvider } from './providers/video-provider.js';
import { ResearchProvider } from './providers/research-provider.js';

export class ProviderRegistry {
  constructor(providers) {
    const list = providers ?? [
      new GroqProvider(),
      new CodeProvider(),
      new ImageProvider(),
      new VideoProvider(),
      new ResearchProvider(),
    ];
    this._byType = new Map(list.map((p) => [p.taskType, p]));
    this._byId = new Map(list.map((p) => [p.id, p]));
  }

  resolve(taskType) {
    return this._byType.get(taskType) ?? this._byType.get(TaskType.TEXT);
  }

  findById(id) {
    return this._byId.get(id) ?? null;
  }

  list() {
    return [...this._byType.values()];
  }

  register(provider) {
    this._byType.set(provider.taskType, provider);
    this._byId.set(provider.id, provider);
  }
}
