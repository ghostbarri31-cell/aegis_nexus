/**
 * AI Router routes — /api/v1/ai/*
 */
import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { aiRouterController } from './ai-router.controller.js';

export const aiRouterRoutes = Router();

aiRouterRoutes.use(authenticate);
aiRouterRoutes.get('/providers', aiRouterController.listProviders);
aiRouterRoutes.post('/route', aiRouterController.route);
