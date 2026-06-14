import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-text wrapper for the voice input button.
class VoiceInputService {
  VoiceInputService() : _speech = SpeechToText();

  final SpeechToText _speech;
  bool _initialized = false;
  bool _listening = false;
  String? _lastError;

  bool get isListening => _listening;
  bool get isAvailable => _initialized;
  String? get lastError => _lastError;

  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize(
        onError: (error) => _lastError = error.errorMsg,
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _listening = false;
          }
        },
      );
      return _initialized;
    } catch (e) {
      _lastError = e.toString();
      _initialized = false;
      return false;
    }
  }

  Future<void> startListening({
    required void Function(String words) onPartialResult,
    required void Function(String words) onFinalResult,
    String localeId = 'en_US',
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    if (_listening) {
      await stopListening();
    }
    _lastError = null;
    _listening = true;
    await _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords;
        if (result.finalResult) {
          onFinalResult(text);
        } else {
          onPartialResult(text);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_listening) {
      await _speech.stop();
    }
    _listening = false;
  }

  Future<List<LocaleName>> locales() async {
    if (!_initialized) await initialize();
    return _speech.locales();
  }

  void dispose() {
    _speech.cancel();
    _listening = false;
  }
}
