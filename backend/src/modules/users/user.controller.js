/**
 * User HTTP handlers.
 */
import { userService } from './user.service.js';

export const userController = {
  async getProfile(req, res, next) {
    try {
      const data = await userService.getProfile(req.user.id);
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },

  async updateProfile(req, res, next) {
    try {
      const data = await userService.updateProfile(req.user.id, req.body);
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },
};
