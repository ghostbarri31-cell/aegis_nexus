import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/models/user_model.dart';

class AuthApiService {
  AuthApiService(this._client);

  final ApiClient _client;

  Future<({UserModel user, String token})> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final json = await _client.post('/auth/register', body: {
      'email': email,
      'password': password,
      if (displayName != null && displayName.isNotEmpty) 'displayName': displayName,
    });
    return _parseAuth(json);
  }

  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    return _parseAuth(json);
  }

  Future<UserModel> fetchMe() async {
    final json = await _client.get('/auth/me', auth: true);
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) throw ApiException('Invalid profile response');
    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      role: data['role'] as String? ?? 'user',
    );
  }

  Future<UserModel> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    final json = await _client.patch('/users/me', auth: true, body: {
      'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) throw ApiException('Invalid profile response');
    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      role: data['role'] as String? ?? 'user',
    );
  }

  ({UserModel user, String token}) _parseAuth(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) throw ApiException('Invalid auth response');
    final userJson = data['user'] as Map<String, dynamic>?;
    final token = data['token'] as String?;
    if (userJson == null || token == null) {
      throw ApiException('Invalid auth payload');
    }
    final user = UserModel(
      id: userJson['id'] as String,
      email: userJson['email'] as String? ?? '',
      displayName: userJson['displayName'] as String? ?? '',
      role: userJson['role'] as String? ?? 'user',
    );
    return (user: user, token: token);
  }
}
