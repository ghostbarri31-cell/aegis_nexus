/**
 * User routes — /api/v1/users/*
 */
import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate.js';
import { userController } from './user.controller.js';

export const userRoutes = Router();

userRoutes.use(authenticate);
userRoutes.get('/me', userController.getProfile);
userRoutes.patch('/me', userController.updateProfile);
