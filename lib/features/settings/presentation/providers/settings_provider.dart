import 'package:flutter/foundation.dart';

import '../../../../app/bootstrap.dart';
import '../../data/settings_repository.dart';
import '../../domain/models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository);

  final SettingsRepository _repository;

  AppSettings _settings = const AppSettings();
  bool _loading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _settings = await _repository.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> update(AppSettings settings) async {
    _settings = settings;
    notifyListeners();
    await _repository.save(settings);
  }

  Future<void> setDarkTheme(bool value) =>
      update(_settings.copyWith(darkTheme: value));

  Future<void> setNotifications(bool value) =>
      update(_settings.copyWith(notifications: value));

  Future<void> setAnalytics(bool value) =>
      update(_settings.copyWith(analytics: value));

  Future<void> setLanguage(String language) =>
      update(_settings.copyWith(language: language));

  Future<void> setApiBaseUrl(String url) async {
    await update(_settings.copyWith(apiBaseUrl: url.trim()));
    await AppBootstrap.reconfigureApi();
  }

  Future<void> setVoiceLocale(String locale) =>
      update(_settings.copyWith(voiceLocale: locale));

  Future<void> setSyncWithApi(bool value) async {
    await update(_settings.copyWith(syncWithApi: value));
    await AppBootstrap.reconfigureApi();
  }
}
