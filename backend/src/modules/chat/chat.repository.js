/**
 * Conversations and messages data access.
 */
import { databaseModule } from '../database/index.js';

export const chatRepository = {
  async listConversations(userId, { limit = 50, offset = 0 } = {}) {
    const { rows } = await databaseModule.query(
      `SELECT id, title, is_archived, created_at, updated_at
       FROM conversations
       WHERE user_id = $1 AND is_archived = FALSE
       ORDER BY updated_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset],
    );
    return rows;
  },

  async createConversation(userId, title = 'New conversation') {
    const { rows } = await databaseModule.query(
      `INSERT INTO conversations (user_id, title)
       VALUES ($1, $2)
       RETURNING id, title, created_at, updated_at`,
      [userId, title],
    );
    return rows[0];
  },

  async getConversation(userId, conversationId) {
    const { rows } = await databaseModule.query(
      `SELECT id, title, is_archived, created_at, updated_at
       FROM conversations
       WHERE id = $1 AND user_id = $2`,
      [conversationId, userId],
    );
    return rows[0] ?? null;
  },

  async listMessages(conversationId, { limit = 100 } = {}) {
    const { rows } = await databaseModule.query(
      `SELECT id, role, content, metadata, created_at
       FROM messages
       WHERE conversation_id = $1
       ORDER BY created_at ASC
       LIMIT $2`,
      [conversationId, limit],
    );
    return rows;
  },

  async addMessage(conversationId, { role, content, metadata = {} }) {
    const { rows } = await databaseModule.query(
      `INSERT INTO messages (conversation_id, role, content, metadata)
       VALUES ($1, $2, $3, $4)
       RETURNING id, role, content, metadata, created_at`,
      [conversationId, role, content, JSON.stringify(metadata)],
    );
    await databaseModule.query(
      `UPDATE conversations SET updated_at = NOW() WHERE id = $1`,
      [conversationId],
    );
    return rows[0];
  },
};
