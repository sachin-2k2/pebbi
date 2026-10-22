import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'speech_recognizer_service.dart';

/// Real implementation of [SpeechRecognizerService] using `speech_to_text`.
class SpeechToTextRecognizerService implements SpeechRecognizerService {
  SpeechToTextRecognizerService({stt.SpeechToText? speech})
      : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  final StreamController<double> _soundLevelController =
      StreamController<double>.broadcast();

  bool _initialized = false;
  bool _hasPermission = false;

  @override
  bool get isAvailable => _initialized && _speech.isAvailable;

  @override
  bool get isListening => _speech.isListening;

  @override
  bool get hasPermission => _hasPermission;

  @override
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  @override
  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    try {
      _initialized = await _speech.initialize(
        onStatus: (status) => onStatus?.call(status),
        onError: (errorNotification) =>
            onError?.call(errorNotification.errorMsg),
        debugLogging: false,
      );
      _hasPermission = await _speech.hasPermission;
      return _initialized;
    } catch (e) {
      onError?.call(e.toString());
      _initialized = false;
      _hasPermission = false;
      return false;
    }
  }

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      onSoundLevelChange: (level) {
        final normalized = (level / 10.0).clamp(0.0, 1.0);
        if (!_soundLevelController.isClosed) {
          _soundLevelController.add(normalized);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: false,
        partialResults: true,
        localeId: localeId,
        listenFor: listenFor,
        pauseFor: pauseFor,
      ),
    );
  }

  @override
  Future<void> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  @override
  Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _soundLevelController.close();
  }
}
