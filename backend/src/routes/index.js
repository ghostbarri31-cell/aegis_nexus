/**
 * API v1 route aggregator.
 */
import { Router } from 'express';
import { authRoutes } from '../modules/auth/auth.routes.js';
import { userRoutes } from '../modules/users/user.routes.js';
import { chatRoutes } from '../modules/chat/chat.routes.js';
import { aiRouterRoutes } from '../modules/ai-router/ai-router.routes.js';

export const apiRouter = Router();

apiRouter.use('/auth', authRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/chat', chatRoutes);
apiRouter.use('/ai', aiRouterRoutes);
