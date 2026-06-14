/**
 * User profile data access.
 */
import { databaseModule } from '../database/index.js';

export const userRepository = {
  async findById(id) {
    const { rows } = await databaseModule.query(
      `SELECT id, email, display_name, avatar_url, role, created_at, updated_at
       FROM users WHERE id = $1 AND is_active = TRUE`,
      [id],
    );
    return rows[0] ?? null;
  },

  async updateProfile(id, { displayName, avatarUrl }) {
    const { rows } = await databaseModule.query(
      `UPDATE users
       SET display_name = COALESCE($2, display_name),
           avatar_url = COALESCE($3, avatar_url)
       WHERE id = $1 AND is_active = TRUE
       RETURNING id, email, display_name, avatar_url, role, updated_at`,
      [id, displayName ?? null, avatarUrl ?? null],
    );
    return rows[0] ?? null;
  },
};
