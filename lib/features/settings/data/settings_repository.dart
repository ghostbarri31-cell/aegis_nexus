import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../domain/models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._storage);

  final StorageService _storage;

  Future<AppSettings> load() async {
    final map = _storage.loadJsonMap(StorageService.keySettings);
    if (map == null) {
      return const AppSettings(apiBaseUrl: AppConstants.apiBaseUrl);
    }
    return AppSettings.fromJson(map);
  }

  Future<void> save(AppSettings settings) async {
    await _storage.saveJsonMap(StorageService.keySettings, settings.toJson());
  }
}
