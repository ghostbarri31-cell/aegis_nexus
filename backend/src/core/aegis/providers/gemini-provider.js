import { TaskType, ExecutionStatus } from '../task-types.js';
import { GeminiClient } from '../clients/gemini-client.js';

export class GeminiProvider {
  constructor({ client } = {}) {
    this.id = 'aegis-gemini';
    this.name = 'Google Gemini';
    this.taskType = TaskType.TEXT;
    this.isMock = false;
    this._client = client ?? new GeminiClient();
  }

  async execute(request, _classification) {
    const started = Date.now();
    const prompt = this._buildPrompt(request);

    try {
      const content = await this._client.generateWithRetry(prompt);
      return {
        taskType: this.taskType,
        providerId: this.id,
        providerName: this.name,
        executionStatus: ExecutionStatus.COMPLETED,
        content,
        isMock: false,
        durationMs: Date.now() - started,
      };
    } catch (error) {
      const message = this._formatError(error);
      return {
        taskType: this.taskType,
        providerId: this.id,
        providerName: this.name,
        executionStatus: ExecutionStatus.FAILED,
        content: message,
        errorMessage: message,
        isMock: false,
        durationMs: Date.now() - started,
      };
    }
  }

  _buildPrompt(request) {
    const base = String(request.prompt ?? '').trim();
    if (request.attachmentName && !base) {
      return `The user attached a file named "${request.attachmentName}". Explain how you would help.`;
    }
    if (request.attachmentName) {
      return `${base}\n\n[Attached file: ${request.attachmentName}]`;
    }
    return base;
  }

  _formatError(error) {
    if (error.code === 'INVALID_API_KEY') {
      return 'Invalid or missing GEMINI_API_KEY. Check your backend .env file.';
    }
    if (error.code === 'TIMEOUT') {
      return 'Gemini request timed out. Please try again.';
    }
    return `Gemini error: ${error.message}`;
  }
}
