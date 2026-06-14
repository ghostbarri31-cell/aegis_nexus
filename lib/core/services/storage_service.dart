import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Key-value persistence for app data (conversations, messages, user, settings).
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String keyConversations = 'aegis_conversations';
  static const String keyMessages = 'aegis_messages';
  static const String keyUser = 'aegis_user';
  static const String keySettings = 'aegis_settings';
  static const String keyInitialized = 'aegis_data_initialized';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    final p = _prefs;
    if (p == null) {
      throw StateError('StorageService.init() must be called before use');
    }
    return p;
  }

  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  String? getString(String key) => prefs.getString(key);

  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> saveJsonList(String key, List<Map<String, dynamic>> items) async {
    await setString(key, jsonEncode(items));
  }

  List<Map<String, dynamic>> loadJsonList(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveJsonMap(String key, Map<String, dynamic> map) async {
    await setString(key, jsonEncode(map));
  }

  Map<String, dynamic>? loadJsonMap(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }
}
