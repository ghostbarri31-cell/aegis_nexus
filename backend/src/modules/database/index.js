/**
 * Database module — connection pool and query helpers.
 */
import pg from 'pg';
import { config } from '../../config/index.js';

const { Pool } = pg;

let pool = null;

export const databaseModule = {
  async connect() {
    if (!config.databaseUrl) {
      console.warn('[Database] DATABASE_URL not set — API will run without DB (dev only)');
      return;
    }
    pool = new Pool({
      connectionString: config.databaseUrl,
      max: config.dbPoolMax,
    });
    const client = await pool.connect();
    await client.query('SELECT 1');
    client.release();
    console.log('[Database] Connected to PostgreSQL');
  },

  async disconnect() {
    if (pool) {
      await pool.end();
      pool = null;
      console.log('[Database] Disconnected');
    }
  },

  getPool() {
    if (!pool) {
      throw new Error('Database pool is not initialized. Set DATABASE_URL and restart.');
    }
    return pool;
  },

  async query(text, params) {
    return databaseModule.getPool().query(text, params);
  },
};
