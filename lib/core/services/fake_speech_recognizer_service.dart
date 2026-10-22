import 'dart:async';
import 'speech_recognizer_service.dart';

/// In-memory fake implementation of [SpeechRecognizerService] for tests and previews.
class FakeSpeechRecognizerService implements SpeechRecognizerService {
  FakeSpeechRecognizerService({
    this.isAvailable = true,
    this.hasPermission = true,
    this.autoInitializeResult = true,
  });

  @override
  bool isAvailable;

  @override
  bool hasPermission;

  bool autoInitializeResult;
  bool isInitialized = false;

  bool _isListening = false;
  @override
  bool get isListening => _isListening;

  final StreamController<double> _soundLevelController =
      StreamController<double>.broadcast();

  @override
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  void Function(String words, bool isFinal)? activeResultCallback;
  String? activeLocaleId;

  int listenCallCount = 0;
  int stopCallCount = 0;
  int cancelCallCount = 0;

  @override
  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  }) async {
    isInitialized = autoInitializeResult;
    return autoInitializeResult;
  }

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    listenCallCount++;
    activeLocaleId = localeId;
    activeResultCallback = onResult;
    _isListening = true;
  }

  /// Helper for tests to simulate speech recognized by the microphone.
  void simulateSpeech(String words, {bool isFinal = true}) {
    activeResultCallback?.call(words, isFinal);
  }

  /// Helper for tests to simulate audio volume fluctuation.
  void simulateSoundLevel(double level) {
    if (!_soundLevelController.isClosed) {
      _soundLevelController.add(level);
    }
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
    _isListening = false;
  }

  @override
  Future<void> cancel() async {
    cancelCallCount++;
    _isListening = false;
  }

  @override
  void dispose() {
    _isListening = false;
    _soundLevelController.close();
  }
}
