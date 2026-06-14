/**
 * Centralized configuration from environment variables.
 */
import dotenv from 'dotenv';

dotenv.config();

function requireEnv(key, fallback = undefined) {
  const value = process.env[key] ?? fallback;
  if (value === undefined || value === '') {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

export const config = {
  env: process.env.NODE_ENV ?? 'development',
  port: Number(process.env.PORT ?? 3000),
  apiPrefix: process.env.API_PREFIX ?? '/api/v1',
  databaseUrl: process.env.DATABASE_URL,
  dbPoolMax: Number(process.env.DB_POOL_MAX ?? 10),
  jwt: {
    secret: process.env.JWT_SECRET ?? 'dev-only-change-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN ?? '7d',
  },
  bcryptRounds: Number(process.env.BCRYPT_ROUNDS ?? 12),
  corsOrigins: (process.env.CORS_ORIGINS ?? 'http://localhost:8080,http://localhost:58923')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean),
  gemini: {
    apiKey: process.env.GEMINI_API_KEY ?? '',
    model: process.env.GEMINI_MODEL ?? 'gemini-2.0-flash',
    timeoutMs: Number(process.env.GEMINI_TIMEOUT_MS ?? 30000),
    maxRetries: Number(process.env.GEMINI_MAX_RETRIES ?? 3),
  },
};

export function assertConfig() {
  if (!config.databaseUrl && config.env === 'production') {
    throw new Error('DATABASE_URL is required in production');
  }
  if (!config.gemini.apiKey || config.gemini.apiKey === 'YOUR_API_KEY' || config.gemini.apiKey.trim() === '') {
    throw new Error('GEMINI_API_KEY is required. Set it in your .env file.');
  }
}
