/**
 * Authentication routes — /api/v1/auth/*
 */
import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { authController } from './auth.controller.js';

export const authRoutes = Router();

authRoutes.post('/register', authController.register);
authRoutes.post('/login', authController.login);
authRoutes.get('/me', authenticate, authController.me);
