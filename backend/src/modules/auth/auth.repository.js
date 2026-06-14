/**
 * Auth data access — user credentials lookup and creation.
 */
import { databaseModule } from '../database/index.js';

export const authRepository = {
  async findByEmail(email) {
    const { rows } = await databaseModule.query(
      `SELECT id, email, password_hash, display_name, role, is_active
       FROM users WHERE email = $1`,
      [email.toLowerCase()],
    );
    return rows[0] ?? null;
  },

  async createUser({ email, passwordHash, displayName }) {
    const { rows } = await databaseModule.query(
      `INSERT INTO users (email, password_hash, display_name)
       VALUES ($1, $2, $3)
       RETURNING id, email, display_name, role, created_at`,
      [email.toLowerCase(), passwordHash, displayName ?? ''],
    );
    return rows[0];
  },
};
