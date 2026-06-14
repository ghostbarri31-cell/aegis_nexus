import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    StorageService? storage,
  })  : _http = httpClient ?? http.Client(),
        _storage = storage ?? StorageService.instance;

  String baseUrl;
  final http.Client _http;
  final StorageService _storage;

  void updateBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static const String _tokenKey = 'aegis_auth_token';

  String? get token => _storage.getString(_tokenKey);
  bool get hasToken => token != null && token!.isNotEmpty;

  Future<void> setToken(String? value) async {
    if (value == null || value.isEmpty) {
      await _storage.prefs.remove(_tokenKey);
    } else {
      await _storage.setString(_tokenKey, value);
    }
  }

  Uri _uri(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Map<String, String> _headers({bool auth = false, String? contentType}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (contentType != null) 'Content-Type': contentType,
    };
    if (auth && hasToken) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final response = await _http.get(_uri(path), headers: _headers(auth: auth));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final response = await _http.post(
      _uri(path),
      headers: _headers(auth: auth, contentType: 'application/json'),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final response = await _http.patch(
      _uri(path),
      headers: _headers(auth: auth, contentType: 'application/json'),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic>? json;
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) json = decoded;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json ?? <String, dynamic>{'success': true};
    }

    final error = json?['error'];
    final message = error is Map
        ? (error['message'] as String? ?? 'Request failed')
        : 'Request failed (${response.statusCode})';
    final code = error is Map ? error['code'] as String? : null;
    throw ApiException(message, statusCode: response.statusCode, code: code);
  }

  void dispose() => _http.close();
}
