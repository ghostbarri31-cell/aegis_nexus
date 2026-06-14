/**
 * Applies database/schema.sql using DATABASE_URL from .env
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import pg from 'pg';

dotenv.config({ path: path.join(path.dirname(fileURLToPath(import.meta.url)), '..', '.env') });

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const schemaPath = path.join(__dirname, '..', 'database', 'schema.sql');

async function migrate() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    console.error('DATABASE_URL is not set. Copy backend/.env.example to backend/.env');
    process.exit(1);
  }

  const sql = fs.readFileSync(schemaPath, 'utf8');
  const client = new pg.Client({ connectionString });
  await client.connect();
  try {
    await client.query(sql);
    console.log('[Migrate] Schema applied successfully');
  } finally {
    await client.end();
  }
}

migrate().catch((err) => {
  console.error('[Migrate] Failed:', err.message);
  process.exit(1);
});
