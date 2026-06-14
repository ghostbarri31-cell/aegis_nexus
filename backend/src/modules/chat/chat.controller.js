/**
 * Chat HTTP handlers.
 */
import { chatService } from './chat.service.js';

export const chatController = {
  async listConversations(req, res, next) {
    try {
      const data = await chatService.listConversations(req.user.id, req.query);
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },

  async createConversation(req, res, next) {
    try {
      const data = await chatService.createConversation(req.user.id, req.body);
      res.status(201).json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },

  async getConversation(req, res, next) {
    try {
      const data = await chatService.getConversation(req.user.id, req.params.id);
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },

  async getMessages(req, res, next) {
    try {
      const data = await chatService.getMessages(req.user.id, req.params.id);
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },

  async sendMessage(req, res, next) {
    try {
      const data = await chatService.sendMessage(req.user.id, req.params.id, req.body);
      res.status(201).json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },
};
