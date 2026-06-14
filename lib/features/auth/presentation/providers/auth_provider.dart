import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/auth_api_service.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthRepository localRepository,
    AuthApiService? api,
    ApiClient? apiClient,
  })  : _local = localRepository,
        _api = api,
        _apiClient = apiClient;

  final AuthRepository _local;
  final AuthApiService? _api;
  final ApiClient? _apiClient;

  UserModel? _user;
  bool _loading = true;
  String? _error;
  bool _remoteSession = false;

  UserModel? get user => _user;
  bool get isLoading => _loading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  bool get isRemoteSession => _remoteSession;

  Future<void> loadSession() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (_api != null && _apiClient != null && _apiClient!.hasToken) {
        _user = await _api!.fetchMe();
        _remoteSession = true;
        await _local.saveUser(_user!);
      } else {
        _user = await _local.getCurrentUser();
        _remoteSession = false;
      }
    } catch (e) {
      _user = await _local.getCurrentUser();
      _remoteSession = false;
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    if (_api == null || _apiClient == null) {
      _error = 'API is not configured';
      notifyListeners();
      return false;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api!.login(email: email.trim(), password: password);
      await _apiClient!.setToken(result.token);
      _user = result.user;
      _remoteSession = true;
      await _local.saveUser(_user!);
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_api == null || _apiClient == null) {
      _error = 'API is not configured';
      notifyListeners();
      return false;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api!.register(
        email: email.trim(),
        password: password,
        displayName: displayName,
      );
      await _apiClient!.setToken(result.token);
      _user = result.user;
      _remoteSession = true;
      await _local.saveUser(_user!);
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    required String email,
    required String bio,
  }) async {
    final current = _user;
    if (current == null) return false;

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      _error = 'Enter a valid email address';
      notifyListeners();
      return false;
    }

    _error = null;
    try {
      UserModel updated;
      if (_remoteSession && _api != null) {
        updated = await _api!.updateProfile(displayName: displayName.trim());
        updated = updated.copyWith(email: trimmedEmail, bio: bio.trim());
      } else {
        updated = current.copyWith(
          displayName: displayName.trim(),
          email: trimmedEmail,
          bio: bio.trim(),
        );
      }
      await _local.saveUser(updated);
      _user = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _apiClient?.setToken(null);
    await _local.signOut();
    _remoteSession = false;
    _user = null;
    notifyListeners();
    await loadSession();
  }
}
