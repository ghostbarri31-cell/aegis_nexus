/**
 * Authentication business logic — register, login, token issuance.
 */
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { config } from '../../config/index.js';
import { AppError } from '../../middleware/errorHandler.js';
import { databaseModule } from '../database/index.js';
import { authRepository } from './auth.repository.js';

function signToken(user) {
  return jwt.sign(
    { email: user.email },
    config.jwt.secret,
    { subject: user.id, expiresIn: config.jwt.expiresIn },
  );
}

function sanitizeUser(user) {
  return {
    id: user.id,
    email: user.email,
    displayName: user.display_name ?? user.displayName,
    role: user.role,
  };
}

export const authService = {
  async register({ email, password, displayName }) {
    if (!email || !password) {
      throw new AppError('Email and password are required', 400, 'VALIDATION_ERROR');
    }
    if (password.length < 8) {
      throw new AppError('Password must be at least 8 characters', 400, 'VALIDATION_ERROR');
    }

    const existing = await authRepository.findByEmail(email);
    if (existing) {
      throw new AppError('Email already registered', 409, 'EMAIL_EXISTS');
    }

    const passwordHash = await bcrypt.hash(password, config.bcryptRounds);
    const user = await authRepository.createUser({ email, passwordHash, displayName });
    const token = signToken(user);

    return { user: sanitizeUser(user), token };
  },

  async login({ email, password }) {
    if (!email || !password) {
      throw new AppError('Email and password are required', 400, 'VALIDATION_ERROR');
    }

    const user = await authRepository.findByEmail(email);
    if (!user || !user.is_active) {
      throw new AppError('Invalid credentials', 401, 'INVALID_CREDENTIALS');
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      throw new AppError('Invalid credentials', 401, 'INVALID_CREDENTIALS');
    }

    const token = signToken(user);
    return { user: sanitizeUser(user), token };
  },

  async me(userId) {
    const { rows } = await databaseModule.query(
      `SELECT id, email, display_name, avatar_url, role, created_at
       FROM users WHERE id = $1 AND is_active = TRUE`,
      [userId],
    );
    const user = rows[0];
    if (!user) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }
    return {
      id: user.id,
      email: user.email,
      displayName: user.display_name,
      avatarUrl: user.avatar_url,
      role: user.role,
      createdAt: user.created_at,
    };
  },
};
