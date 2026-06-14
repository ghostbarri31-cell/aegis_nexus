/**
 * JWT authentication middleware (V1 structure).
 * Validates Bearer tokens and attaches user payload to req.user.
 */
import jwt from 'jsonwebtoken';
import { config } from '../config/index.js';
import { AppError } from './errorHandler.js';

export function authenticate(req, _res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return next(new AppError('Authentication required', 401, 'UNAUTHORIZED'));
  }

  const token = header.slice(7);
  try {
    const payload = jwt.verify(token, config.jwt.secret);
    req.user = { id: payload.sub, email: payload.email };
    next();
  } catch {
    next(new AppError('Invalid or expired token', 401, 'INVALID_TOKEN'));
  }
}

export function optionalAuthenticate(req, _res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return next();
  }
  try {
    const payload = jwt.verify(header.slice(7), config.jwt.secret);
    req.user = { id: payload.sub, email: payload.email };
  } catch {
    /* ignore invalid optional token */
  }
  next();
}
