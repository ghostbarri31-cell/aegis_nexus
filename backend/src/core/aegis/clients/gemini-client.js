import { config } from '../../../config/index.js';

export class GeminiClient {
  constructor(options = {}) {
    this.apiKey = options.apiKey ?? config.gemini.apiKey;
    this.model = options.model ?? config.gemini.model;
    this.timeoutMs = options.timeoutMs ?? config.gemini.timeoutMs;
    this.maxRetries = options.maxRetries ?? config.gemini.maxRetries;
  }

  get hasApiKey() {
    return Boolean(this.apiKey && this.apiKey !== 'YOUR_API_KEY');
  }

  async generateWithRetry(prompt) {
    if (!this.hasApiKey) {
      const err = new Error('Invalid or missing GEMINI_API_KEY');
      err.code = 'INVALID_API_KEY';
      throw err;
    }

    const trimmed = String(prompt ?? '').trim();
    if (!trimmed) {
      const err = new Error('Prompt cannot be empty');
      err.code = 'VALIDATION_ERROR';
      throw err;
    }

    let lastError;
    for (let attempt = 0; attempt < this.maxRetries; attempt += 1) {
      try {
        return await this._generateOnce(trimmed);
      } catch (error) {
        lastError = error;
        if (!this._isRetryable(error) || attempt >= this.maxRetries - 1) {
          throw error;
        }
        await new Promise((r) => setTimeout(r, 400 * (attempt + 1)));
      }
    }
    throw lastError;
  }

  async _generateOnce(prompt) {
    const url =
      `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent?key=${this.apiKey}`;

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        signal: controller.signal,
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
        }),
      });

      const body = await response.json().catch(() => ({}));

      if (!response.ok) {
        const message = body?.error?.message ?? `Gemini HTTP ${response.status}`;
        const err = new Error(message);
        err.status = response.status;
        if (response.status === 401 || response.status === 403) {
          err.code = 'INVALID_API_KEY';
        } else if (response.status === 429 || response.status >= 500) {
          err.code = 'RETRYABLE';
        }
        throw err;
      }

      const text = body?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!text || !String(text).trim()) {
        const err = new Error('Gemini returned an empty response');
        err.code = 'EMPTY_RESPONSE';
        throw err;
      }

      return String(text).trim();
    } catch (error) {
      if (error.name === 'AbortError') {
        const err = new Error('Gemini request timed out');
        err.code = 'TIMEOUT';
        throw err;
      }
      throw error;
    } finally {
      clearTimeout(timer);
    }
  }

  _isRetryable(error) {
    return error.code === 'RETRYABLE' || error.code === 'TIMEOUT';
  }
}
