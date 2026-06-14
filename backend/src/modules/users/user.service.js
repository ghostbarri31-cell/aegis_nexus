/**
 * User profile business logic.
 */
import { AppError } from '../../middleware/errorHandler.js';
import { userRepository } from './user.repository.js';

function mapUser(row) {
  return {
    id: row.id,
    email: row.email,
    displayName: row.display_name,
    avatarUrl: row.avatar_url,
    role: row.role,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export const userService = {
  async getProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }
    return mapUser(user);
  },

  async updateProfile(userId, body) {
    const updated = await userRepository.updateProfile(userId, {
      displayName: body.displayName,
      avatarUrl: body.avatarUrl,
    });
    if (!updated) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }
    return mapUser(updated);
  },
};
