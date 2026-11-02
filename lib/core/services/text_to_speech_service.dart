import 'dart:async';
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
  /// Optional [speechRate] overrides the default rate (e.g. 0.25 for slow).
  /// Optional [onCompletion] is invoked when the speech engine finishes utterance.
  /// Returns `true` if playback initiated successfully, or `false` quietly if
  /// the language voice is unavailable on the device.
  Future<bool> speak(
    String text, {
    required String locale,
    double? speechRate,
    VoidCallback? onCompletion,
  });

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
    _tts.setSpeechRate(0.50);
    _tts.setPitch(1.0);
    _tts.awaitSpeakCompletion(true);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _tts.getEngines.then((engines) {
        if (engines is List && engines.contains('com.google.android.tts')) {
          _tts.setEngine('com.google.android.tts');
        }
      }).catchError((_) {});
    }
    _initialized = true;
  }

  /// Resolves an ISO language code (e.g. 'en', 'es', 'fr', 'ml') to a BCP-47 speech locale tag.
  static String resolveLocale(String? langCode) {
    switch (langCode?.toLowerCase().trim()) {
      case 'ml':
        return 'ml-IN';
      case 'hi':
        return 'hi-IN';
      case 'ta':
        return 'ta-IN';
      case 'te':
        return 'te-IN';
      case 'kn':
        return 'kn-IN';
      case 'es':
        return 'es-ES';
      case 'ar':
        return 'ar-SA';
      case 'fr':
        return 'fr-FR';
      case 'de':
        return 'de-DE';
      case 'ja':
        return 'ja-JP';
      case 'en':
      default:
        return 'en-US';
    }
  }

  /// Strips emojis and parenthesized transliterations so TTS doesn't read both.
  static String cleanAudioText(String text) {
    if (text.trim().isEmpty) return text;
    final withoutEmojis = text.replaceAll(
      RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      ),
      '',
    );
    final withoutParens = withoutEmojis
        .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s*\[[^\]]*\]'), '')
        .trim();
    if (withoutParens.isNotEmpty) return withoutParens;
    return withoutEmojis
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim();
  }

  @override
  Future<bool> speak(
    String text, {
    required String locale,
    double? speechRate,
    VoidCallback? onCompletion,
  }) async {
    try {
      final isAvailable = await _tts.isLanguageAvailable(locale);
      if (isAvailable == 0 || isAvailable == false) {
        debugPrint('TTS: Voice not available for locale: $locale');
        return false;
      }

      await _tts.stop();
      if (onCompletion != null) {
        _tts.setCompletionHandler(() => onCompletion());
      }
      await _tts.setLanguage(locale);
      if (speechRate != null) {
        await _tts.setSpeechRate(speechRate);
      } else {
        await _tts.setSpeechRate(0.50);
      }
      final cleanText = cleanAudioText(text);
      final result = await _tts.speak(cleanText);
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

/// Simulation behavior modes for [FakeSpeechService] in test suites.
enum FakeTtsMode { normal, error, neverCompleting, lateCompletion }

/// In-memory fake implementation of [TextToSpeechService] for unit and widget tests.
class FakeSpeechService implements TextToSpeechService {
  FakeSpeechService({
    this.supportedLocales,
    this.mode = FakeTtsMode.normal,
    this.completionDelay = Duration.zero,
    this.lateCompletionDelay = const Duration(seconds: 15),
  });

  /// Optional set of supported locales. If null, all locales succeed.
  final Set<String>? supportedLocales;
  FakeTtsMode mode;
  final Duration completionDelay;
  final Duration lateCompletionDelay;

  final List<({String text, String locale, double? speechRate})> spokenHistory =
      [];
  String? lastSpokenText;
  String? lastLocale;
  double? lastSpeechRate;
  bool isSpeaking = false;
  int get speakCallCount => spokenHistory.length;
  int stopCallCount = 0;

  @override
  Future<bool> speak(
    String text, {
    required String locale,
    double? speechRate,
    VoidCallback? onCompletion,
  }) async {
    isSpeaking = false;
    stopCallCount++;

    if (supportedLocales != null && !supportedLocales!.contains(locale)) {
      return false;
    }

    if (mode == FakeTtsMode.error) {
      return false;
    }

    final cleaned = FlutterTtsService.cleanAudioText(text);
    lastSpokenText = cleaned;
    lastLocale = locale;
    lastSpeechRate = speechRate;
    isSpeaking = true;
    spokenHistory.add((text: cleaned, locale: locale, speechRate: speechRate));

    if (mode == FakeTtsMode.normal && onCompletion != null) {
      if (completionDelay == Duration.zero) {
        scheduleMicrotask(onCompletion);
      } else {
        Future<void>.delayed(completionDelay, onCompletion);
      }
    } else if (mode == FakeTtsMode.lateCompletion && onCompletion != null) {
      Future<void>.delayed(lateCompletionDelay, onCompletion);
    }

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

typedef FakeTextToSpeechService = FakeSpeechService;
