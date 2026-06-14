import { aiRouterService } from './ai-router.service.js';

export const aiRouterController = {
  async listProviders(_req, res, next) {
    try {
      const data = aiRouterService.listProviders();
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },

  async route(req, res, next) {
    try {
      const data = await aiRouterService.route(req.body);
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  },
};
