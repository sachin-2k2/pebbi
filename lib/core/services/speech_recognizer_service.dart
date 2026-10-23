import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'speech_to_text_recognizer_service.dart';

/// Abstract service interface for device speech recognition.
///
/// Follows AGENTS.md §2.1 & §5.1: Abstraction keeps domain and UI testable
/// with fakes and independent of third-party STT SDKs.
abstract class SpeechRecognizerService {
  /// Whether speech recognition is supported and initialized on this device.
  bool get isAvailable;

  /// Whether the microphone is currently actively listening.
  bool get isListening;

  /// Whether the app currently holds microphone and speech permissions.
  bool get hasPermission;

  /// Stream of normalized sound levels (0.0 to 1.0) while listening.
  Stream<double> get soundLevelStream;

  /// Initializes the speech recognizer engine and checks permissions.
  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(String error)? onError,
  });

  /// Starts listening to the microphone for the given [localeId] (e.g. 'es-ES', 'ja-JP').
  ///
  /// Delivers continuous partial or final recognized words to [onResult].
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
    Duration? listenFor,
    Duration? pauseFor,
  });

  /// Stops listening and commits the final recognized speech.
  Future<void> stop();

  /// Cancels listening and discards buffered speech.
  Future<void> cancel();

  /// Releases resources.
  void dispose();
}

/// Riverpod provider for the application [SpeechRecognizerService].
final speechRecognizerServiceProvider =
    Provider<SpeechRecognizerService>((ref) {
  final service = SpeechToTextRecognizerService();
  ref.onDispose(() => service.dispose());
  return service;
});
