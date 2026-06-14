/**
 * HTTP server entry point.
 * Loads environment, builds the Express app, and listens on PORT.
 */
import { config, assertConfig } from './config/index.js';
import { createApp } from './app.js';
import { databaseModule } from './modules/database/index.js';

async function bootstrap() {
  assertConfig();
  await databaseModule.connect();

  const app = createApp();
  const server = app.listen(config.port, () => {
    console.log(`[Aegis Nexus API] ${config.env} — http://localhost:${config.port}${config.apiPrefix}`);
  });

  const shutdown = async (signal) => {
    console.log(`[Aegis Nexus API] ${signal} received, shutting down…`);
    server.close(async () => {
      await databaseModule.disconnect();
      process.exit(0);
    });
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

bootstrap().catch((err) => {
  console.error('[Aegis Nexus API] Failed to start:', err);
  process.exit(1);
});
