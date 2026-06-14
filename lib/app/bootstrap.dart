import '../core/aegis/routing/provider_registry.dart';
import '../core/aegis/routing/router_service.dart';
import '../core/aegis/routing/task_classifier.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/services/storage_service.dart';
import '../features/auth/data/auth_api_service.dart';
import '../features/auth/data/local_auth_repository.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/chat/data/chat_api_service.dart';
import '../features/chat/data/local_chat_repository.dart';
import '../features/chat/presentation/providers/chat_provider.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/presentation/providers/settings_provider.dart';

class AppBootstrap {
  AppBootstrap._();

  static late final ChatProvider chatProvider;
  static late final AuthProvider authProvider;
  static late final SettingsProvider settingsProvider;
  static late final ApiClient apiClient;
  static late final RouterService routerService;
  static ChatApiService? chatApi;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await StorageService.instance.init();

    final storage = StorageService.instance;
    final settingsRepository = SettingsRepository(storage);
    settingsProvider = SettingsProvider(settingsRepository);
    await settingsProvider.load();

    final baseUrl = settingsProvider.settings.apiBaseUrl.isNotEmpty
        ? settingsProvider.settings.apiBaseUrl
        : AppConstants.apiBaseUrl;

    apiClient = ApiClient(baseUrl: baseUrl, storage: storage);
    final authApi = AuthApiService(apiClient);
    chatApi = ChatApiService(apiClient);

    routerService = RouterService(
      classifier: const TaskClassifier(),
      registry: ProviderRegistry(),
    );

    final localChat = LocalChatRepository(storage);
    final localAuth = LocalAuthRepository(storage);

    chatProvider = ChatProvider(
      localChat,
      router: routerService,
      chatApi: settingsProvider.settings.syncWithApi ? chatApi : null,
      apiClient: apiClient,
    );
    authProvider = AuthProvider(
      localRepository: localAuth,
      api: authApi,
      apiClient: apiClient,
    );

    await authProvider.loadSession();
    await chatProvider.initialize();
    _initialized = true;
  }

  static Future<void> reconfigureApi() async {
    final baseUrl = settingsProvider.settings.apiBaseUrl.isNotEmpty
        ? settingsProvider.settings.apiBaseUrl
        : AppConstants.apiBaseUrl;
    apiClient.updateBaseUrl(baseUrl);
    chatApi = ChatApiService(apiClient);
    chatProvider.updateApi(
      settingsProvider.settings.syncWithApi ? chatApi : null,
      apiClient,
    );
    if (settingsProvider.settings.syncWithApi && apiClient.hasToken) {
      await chatProvider.syncFromRemote();
    }
  }
}
