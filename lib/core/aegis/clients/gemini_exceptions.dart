class GeminiException implements Exception {
  GeminiException(this.message, {this.code, this.isRetryable = false});

  final String message;
  final String? code;
  final bool isRetryable;

  @override
  String toString() => message;
}

class GeminiAuthException extends GeminiException {
  GeminiAuthException([String? message])
      : super(
          message ??
              'Invalid or missing GEMINI_API_KEY. Check your .env file.',
          code: 'INVALID_API_KEY',
        );
}

class GeminiTimeoutException extends GeminiException {
  GeminiTimeoutException([String? message])
      : super(
          message ?? 'Gemini request timed out. Please try again.',
          code: 'TIMEOUT',
          isRetryable: true,
        );
}

class GeminiApiException extends GeminiException {
  GeminiApiException(super.message, {super.code, super.isRetryable = false});
}
