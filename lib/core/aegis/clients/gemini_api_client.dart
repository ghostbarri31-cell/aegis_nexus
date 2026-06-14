import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../config/env_loader.dart';
import 'gemini_exceptions.dart';

class GeminiApiClient {
  GeminiApiClient({
    String? apiKey,
    this.modelName = 'gemini-1.5-flash',
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    GenerativeModel Function({required String apiKey, required String model})?
        modelFactory,
  })  : _apiKey = apiKey ?? EnvLoader.geminiApiKey,
        _modelFactory = modelFactory ??
            (({required apiKey, required model}) => GenerativeModel(
                  model: model,
                  apiKey: apiKey,
                ));

  final String? _apiKey;
  final String modelName;
  final Duration timeout;
  final int maxRetries;
  final GenerativeModel Function({required String apiKey, required String model})
      _modelFactory;

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<String> generateWithRetry(String prompt) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw GeminiAuthException();
    }

    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      throw GeminiApiException('Prompt cannot be empty.');
    }

    Object? lastError;
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await _generateOnce(key, trimmed);
      } catch (e) {
        lastError = e;
        final wrapped = _wrapError(e);
        if (!wrapped.isRetryable || attempt >= maxRetries - 1) {
          throw wrapped;
        }
        await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }

    throw _wrapError(lastError ?? 'Unknown Gemini error');
  }

  Future<String> _generateOnce(String apiKey, String prompt) async {
    final model = _modelFactory(apiKey: apiKey, model: modelName);
    try {
      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(timeout);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw GeminiApiException('Gemini returned an empty response.');
      }
      return text;
    } on TimeoutException {
      throw GeminiTimeoutException();
    }
  }

  GeminiException _wrapError(Object error) {
    if (error is GeminiException) return error;

print('RAW GEMINI ERROR: $error');

    final message = error.toString().toLowerCase();

    if (message.contains('api key') ||
        message.contains('api_key') ||
        message.contains('invalid key') ||
        message.contains('permission denied') ||
        message.contains('401') ||
        message.contains('403')) {
      return GeminiAuthException();
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return GeminiTimeoutException();
    }

    if (message.contains('429') ||
        message.contains('rate') ||
        message.contains('503') ||
        message.contains('500') ||
        message.contains('unavailable')) {
      return GeminiApiException(
        'Gemini is temporarily unavailable. Retrying may help.',
        isRetryable: true,
      );
    }

    return GeminiApiException('Gemini error: $error');
  }
}
