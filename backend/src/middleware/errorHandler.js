/**
 * Global error and 404 handlers for consistent API responses.
 */

export class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;
  }
}

export function notFoundHandler(_req, res) {
  res.status(404).json({
    success: false,
    error: { code: 'NOT_FOUND', message: 'Resource not found' },
  });
}

export function errorHandler(err, _req, res, _next) {
  const statusCode = err.statusCode ?? 500;
  const code = err.code ?? 'INTERNAL_ERROR';
  const message = err.isOperational ? err.message : 'An unexpected error occurred';

  if (process.env.NODE_ENV !== 'production') {
    console.error('[API Error]', err);
  }

  res.status(statusCode).json({
    success: false,
    error: { code, message },
  });
}
