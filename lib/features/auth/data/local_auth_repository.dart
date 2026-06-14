import 'package:uuid/uuid.dart';

import '../../../core/services/storage_service.dart';
import '../domain/models/user_model.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._storage, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final StorageService _storage;
  final Uuid _uuid;

  @override
  Future<UserModel?> getCurrentUser() async {
    final map = _storage.loadJsonMap(StorageService.keyUser);
    if (map != null) {
      return UserModel.fromJson(map);
    }
    final user = UserModel(
      id: _uuid.v4(),
      email: 'operator@aegis-nexus.io',
      displayName: 'Alex Operator',
      role: 'user',
      bio: 'AI orchestration operator',
    );
    await saveUser(user);
    return user;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.saveJsonMap(StorageService.keyUser, user.toJson());
  }

  @override
  Future<void> signOut() async {
    await _storage.prefs.remove(StorageService.keyUser);
  }
}
