import { RouterService } from '../../core/aegis/router-service.js';

const routerService = new RouterService();

export const aiRouterService = {
  listProviders() {
    return routerService.listProviders();
  },

  async route(payload) {
    const request = {
      prompt: payload?.prompt ?? payload?.content ?? '',
      attachmentName: payload?.attachmentName ?? null,
      conversationId: payload?.conversationId ?? null,
    };

    const progress = [];
    const result = await routerService.route(request, (info) => progress.push({ ...info }));

    return {
      routed: true,
      ...result,
      progress,
    };
  },
};

export { routerService };
