/**
 * Chat routes — /api/v1/chat/*
 */
import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { chatController } from './chat.controller.js';

export const chatRoutes = Router();

chatRoutes.use(authenticate);
chatRoutes.get('/conversations', chatController.listConversations);
chatRoutes.post('/conversations', chatController.createConversation);
chatRoutes.get('/conversations/:id', chatController.getConversation);
chatRoutes.get('/conversations/:id/messages', chatController.getMessages);
chatRoutes.post('/conversations/:id/messages', chatController.sendMessage);
