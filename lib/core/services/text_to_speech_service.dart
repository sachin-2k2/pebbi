import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Abstract service for synthesizing speech audio across locales.
///
/// Follows AGENTS.md §2.1 & §2.4: service abstraction allowing clean swaps
/// between FlutterTTS, pre-recorded audio clips, or fake test doubles.
abstract interface class TextToSpeechService {
  /// Speaks [text] in the requested [locale] (e.g. 'es-ES', 'ja-JP').
  ///
  /// Returns `true` if playback initiated successfully, or `false` quietly if
  /// the language voice is unavailable on the device.
  Future<bool> speak(String text, {required String locale});

  /// Stops any currently playing speech.
  Future<void> stop();

  /// Releases underlying engine resources.
  void dispose();
}

/// Production implementation of [TextToSpeechService] backed by `flutter_tts`.
class FlutterTtsService implements TextToSpeechService {
  FlutterTtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts() {
    _init();
  }

  final FlutterTts _tts;
  bool _initialized = false;

  void _init() {
    if (_initialized) return;
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
    _initialized = true;
  }

  @override
  Future<bool> speak(String text, {required String locale}) async {
    try {
      final isAvailable = await _tts.isLanguageAvailable(locale);
      if (isAvailable == 0 || isAvailable == false) {
        debugPrint('TTS: Voice not available for locale: $locale');
        return false;
      }

      await _tts.stop();
      await _tts.setLanguage(locale);
      final result = await _tts.speak(text);
      return result == 1;
    } catch (e) {
      debugPrint('TTS: Error speaking text for $locale: $e');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TTS: Error stopping playback: $e');
    }
  }

  @override
  void dispose() {
    try {
      _tts.stop();
    } catch (_) {}
  }
}

/// In-memory fake implementation of [TextToSpeechService] for unit and widget tests.
class FakeSpeechService implements TextToSpeechService {
  FakeSpeechService({this.supportedLocales});

  /// Optional set of supported locales. If null, all locales succeed.
  final Set<String>? supportedLocales;

  final List<({String text, String locale})> spokenHistory = [];
  String? lastSpokenText;
  String? lastLocale;
  bool isSpeaking = false;
  int stopCallCount = 0;

  @override
  Future<bool> speak(String text, {required String locale}) async {
    isSpeaking = false;
    stopCallCount++;

    if (supportedLocales != null && !supportedLocales!.contains(locale)) {
      return false;
    }

    lastSpokenText = text;
    lastLocale = locale;
    isSpeaking = true;
    spokenHistory.add((text: text, locale: locale));
    return true;
  }

  @override
  Future<void> stop() async {
    isSpeaking = false;
    stopCallCount++;
  }

  @override
  void dispose() {
    isSpeaking = false;
  }
}

/// Riverpod provider for the application [TextToSpeechService].
final textToSpeechServiceProvider = Provider<TextToSpeechService>((ref) {
  final service = FlutterTtsService();
  ref.onDispose(() => service.dispose());
  return service;
});
