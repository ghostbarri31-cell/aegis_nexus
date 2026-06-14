/**
 * Chat business logic — conversations and messages with Aegis Core routing.
 */
import { aiRouterService } from '../ai-router/ai-router.service.js';
import { AppError } from '../../middleware/errorHandler.js';
import { chatRepository } from './chat.repository.js';

function mapConversation(row) {
  return {
    id: row.id,
    title: row.title,
    isArchived: row.is_archived,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function mapMessage(row) {
  return {
    id: row.id,
    role: row.role,
    content: row.content,
    metadata: row.metadata,
    routing: row.metadata?.routing ?? null,
    createdAt: row.created_at,
  };
}

export const chatService = {
  async listConversations(userId, query) {
    const rows = await chatRepository.listConversations(userId, query);
    return rows.map(mapConversation);
  },

  async createConversation(userId, { title }) {
    const row = await chatRepository.createConversation(userId, title);
    return mapConversation(row);
  },

  async getConversation(userId, conversationId) {
    const row = await chatRepository.getConversation(userId, conversationId);
    if (!row) {
      throw new AppError('Conversation not found', 404, 'CONVERSATION_NOT_FOUND');
    }
    return mapConversation(row);
  },

  async getMessages(userId, conversationId) {
    await chatService.getConversation(userId, conversationId);
    const rows = await chatRepository.listMessages(conversationId);
    return rows.map(mapMessage);
  },

  async sendMessage(userId, conversationId, { content, role = 'user', attachmentName }) {
    if (!content?.trim()) {
      throw new AppError('Message content is required', 400, 'VALIDATION_ERROR');
    }
    await chatService.getConversation(userId, conversationId);

    const userRow = await chatRepository.addMessage(conversationId, {
      role,
      content: content.trim(),
      metadata: attachmentName ? { attachmentName } : {},
    });

    const routed = await aiRouterService.route({
      prompt: content.trim(),
      attachmentName: attachmentName ?? null,
      conversationId,
    });

    const assistantRow = await chatRepository.addMessage(conversationId, {
      role: 'assistant',
      content: routed.content,
      metadata: {
        routing: routed.routing,
        providerId: routed.providerId,
        taskType: routed.taskType,
      },
    });

    return {
      user: mapMessage(userRow),
      assistant: mapMessage(assistantRow),
      routing: routed.routing,
    };
  },
};
