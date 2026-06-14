import Groq from 'groq-sdk';
import { config } from '../../../config/index.js';

export class GroqClient {
  constructor(options = {}) {
    this.apiKey = options.apiKey ?? config.groq.apiKey;
    this.model = options.model ?? config.groq.model;
    this.timeoutMs = options.timeoutMs ?? config.groq.timeoutMs;
    this.maxRetries = options.maxRetries ?? config.groq.maxRetries;
  }

  get hasApiKey() {
    return Boolean(this.apiKey && this.apiKey !== 'YOUR_API_KEY');
  }

  async generateWithRetry(prompt) {
    if (!this.hasApiKey) {
      const err = new Error('Invalid or missing GROQ_API_KEY');
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
    const client = new Groq({
      apiKey: this.apiKey,
      timeout: this.timeoutMs,
    });

    try {
      const response = await client.chat.completions.create({
        model: this.model,
        messages: [{ role: 'user', content: prompt }],
      });

      const text = response?.choices?.[0]?.message?.content;
      if (!text || !String(text).trim()) {
        const err = new Error('Groq returned an empty response');
        err.code = 'EMPTY_RESPONSE';
        throw err;
      }

      return String(text).trim();
    } catch (error) {
      if (error.code === 'EMPTY_RESPONSE') {
        throw error;
      }

      if (error.name === 'APIConnectionTimeoutError' || error.code === 'ETIMEDOUT') {
        const err = new Error('Groq request timed out');
        err.code = 'TIMEOUT';
        throw err;
      }

      if (error.status === 401 || error.status === 403) {
        const err = new Error(error.message ?? `Groq HTTP ${error.status}`);
        err.code = 'INVALID_API_KEY';
        err.status = error.status;
        throw err;
      }

      if (error.status === 429 || (error.status && error.status >= 500)) {
        const err = new Error(error.message ?? `Groq HTTP ${error.status}`);
        err.code = 'RETRYABLE';
        err.status = error.status;
        throw err;
      }

      throw error;
    }
  }

  _isRetryable(error) {
    return error.code === 'RETRYABLE' || error.code === 'TIMEOUT';
  }
}
