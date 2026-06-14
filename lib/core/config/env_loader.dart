import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  EnvLoader._();

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;

    const candidates = ['.env', 'backend/.env', 'assets/.env'];

    for (final path in candidates) {
      try {
        await dotenv.load(fileName: path, isOptional: true);
        if (dotenv.env['GEMINI_API_KEY']?.trim().isNotEmpty == true) {
          _loaded = true;
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[EnvLoader] Could not load $path: $e');
        }
      }
    }

    _loaded = true;
  }

  static void validate() {
  if (geminiApiKey == null) {
    debugPrint('WARNING: GEMINI_API_KEY not found');

    }
  }

  static String? get geminiApiKey {
    final value = dotenv.env['GEMINI_API_KEY']?.trim();
    if (value == null || value.isEmpty || value == 'YOUR_API_KEY') {
      return null;
    }

    debugPrint('GEMINI KEY LOADED: ${value.substring(0, 10)}...');
    return value;
  }
}
