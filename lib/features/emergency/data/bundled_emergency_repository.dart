import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/emergency_phrase.dart';
import '../domain/emergency_phrasebook.dart';
import '../domain/emergency_repository.dart';

/// Bundled local offline implementation of [EmergencyRepository].
///
/// Follows AGENTS.md §5 (offline-first, client side):
/// - Content is 100% bundled locally with the app.
/// - Zero network requests or remote API calls.
/// - Works reliably in airplane mode, fresh install, or logged-out state.
class BundledEmergencyRepository implements EmergencyRepository {
  BundledEmergencyRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  static Map<String, EmergencyPhrasebook>? _cachedPhrasebooks;

  /// Resets the static phrasebook cache (useful in testing).
  static void resetCache() {
    _cachedPhrasebooks = null;
  }

  static const String _assetPath = 'assets/data/emergency_phrases.json';

  @override
  Future<EmergencyPhrasebook?> getPhrasebook({
    required String targetLanguageCode,
  }) async {
    final catalog = await _loadCatalog();
    return catalog[targetLanguageCode];
  }

  @override
  Future<List<String>> getSupportedLanguages() async {
    final catalog = await _loadCatalog();
    return catalog.keys.toList();
  }

  Future<Map<String, EmergencyPhrasebook>> _loadCatalog() async {
    if (_cachedPhrasebooks != null) {
      return _cachedPhrasebooks!;
    }

    try {
      final jsonStr = await _bundle.loadString(_assetPath);
      final dynamic raw = jsonDecode(jsonStr);

      if (raw is Map<String, dynamic>) {
        final Map<String, EmergencyPhrasebook> parsed = {};
        for (final entry in raw.entries) {
          final langMap = entry.value as Map<String, dynamic>;
          final rawPhrases = langMap['phrases'] as List<dynamic>? ?? [];

          final phrases = rawPhrases.map((p) {
            final pMap = p as Map<String, dynamic>;
            final rawLabels = pMap['labels'] as Map<String, dynamic>? ?? {};
            final labels = rawLabels.map(
              (k, v) => MapEntry(k, v?.toString() ?? ''),
            );

            return EmergencyPhrase(
              id: pMap['id']?.toString() ?? '',
              labels: labels,
              targetText: pMap['targetText']?.toString() ?? '',
              ttsLocale: pMap['ttsLocale']?.toString() ?? 'en-US',
              helperLine: pMap['helperLine']?.toString(),
              genderNote: pMap['genderNote']?.toString(),
              audioAsset: pMap['audioAsset']?.toString(),
            );
          }).toList();

          parsed[entry.key] = EmergencyPhrasebook(
            languageCode: langMap['languageCode']?.toString() ?? entry.key,
            languageName: langMap['languageName']?.toString() ?? '',
            phrases: phrases,
            isReviewed: langMap['isReviewed'] == true,
          );
        }
        _cachedPhrasebooks = parsed;
        return parsed;
      }
    } catch (_) {
      // Fallback to embedded catalog if asset bundle is unavailable (e.g. in standalone unit test)
    }

    _cachedPhrasebooks = _embeddedCatalog;
    return _embeddedCatalog;
  }

  /// In-memory fallback dataset ensuring total resilience offline and in tests.
  static final Map<String, EmergencyPhrasebook> _embeddedCatalog = {
    'es': const EmergencyPhrasebook(
      languageCode: 'es',
      languageName: 'Spanish',
      isReviewed: true,
      phrases: [
        EmergencyPhrase(
          id: 'need_doctor',
          labels: {'en': 'I need a doctor'},
          targetText: 'Necesito un médico',
          ttsLocale: 'es-ES',
        ),
        EmergencyPhrase(
          id: 'call_police',
          labels: {'en': 'Call the police'},
          targetText: 'Llame a la policía, por favor',
          ttsLocale: 'es-ES',
        ),
        EmergencyPhrase(
          id: 'lost',
          labels: {'en': "I'm lost"},
          targetText: 'Estoy perdido',
          ttsLocale: 'es-ES',
          genderNote: 'Grammatically masculine (estoy perdido vs perdida)',
        ),
        EmergencyPhrase(
          id: 'allergic',
          labels: {'en': "I'm allergic to..."},
          targetText: 'Soy alérgico a esto',
          ttsLocale: 'es-ES',
          genderNote:
              'Grammatically masculine; phrasing assumes pointing at item',
        ),
        EmergencyPhrase(
          id: 'dont_understand',
          labels: {'en': "I don't understand"},
          targetText: 'No entiendo',
          ttsLocale: 'es-ES',
        ),
        EmergencyPhrase(
          id: 'where_hospital',
          labels: {'en': 'Where is the hospital?'},
          targetText: '¿Dónde está el hospital?',
          ttsLocale: 'es-ES',
        ),
        EmergencyPhrase(
          id: 'speak_slowly',
          labels: {'en': 'Please speak slowly'},
          targetText: 'Hable más despacio, por favor',
          ttsLocale: 'es-ES',
        ),
        EmergencyPhrase(
          id: 'lost_passport',
          labels: {'en': 'I lost my passport'},
          targetText: 'Perdí mi pasaporte',
          ttsLocale: 'es-ES',
        ),
      ],
    ),
    'fr': const EmergencyPhrasebook(
      languageCode: 'fr',
      languageName: 'French',
      isReviewed: false,
      phrases: [
        EmergencyPhrase(
          id: 'need_doctor',
          labels: {'en': 'I need a doctor'},
          targetText: '',
          ttsLocale: 'fr-FR',
        ),
        EmergencyPhrase(
          id: 'call_police',
          labels: {'en': 'Call the police'},
          targetText: '',
          ttsLocale: 'fr-FR',
        ),
        EmergencyPhrase(
          id: 'lost',
          labels: {'en': "I'm lost"},
          targetText: '',
          ttsLocale: 'fr-FR',
        ),
        EmergencyPhrase(
          id: 'allergic',
          labels: {'en': "I'm allergic to..."},
          targetText: '',
          ttsLocale: 'fr-FR',
        ),
        EmergencyPhrase(
          id: 'dont_understand',
          labels: {'en': "I don't understand"},
          targetText: '',
          ttsLocale: 'fr-FR',
        ),
        EmergencyPhrase(
          id: 'where_hospital',
          labels: {'en': 'Where is the hospital?'},
          targetText: '',
          ttsLocale: 'fr-FR',
        ),
        EmergencyPhrase(
          id: 'speak_slowly',
          labels: {'en': 'Please speak slowly'},
          targetText: '',
          ttsLocale: 'fr-FR',
        ),
        EmergencyPhrase(
          id: 'lost_passport',
          labels: {'en': 'I lost my passport'},
          targetText: '',
          ttsLocale: 'fr-FR',
        ),
      ],
    ),
    'de': const EmergencyPhrasebook(
      languageCode: 'de',
      languageName: 'German',
      isReviewed: false,
      phrases: [
        EmergencyPhrase(
          id: 'need_doctor',
          labels: {'en': 'I need a doctor'},
          targetText: '',
          ttsLocale: 'de-DE',
        ),
        EmergencyPhrase(
          id: 'call_police',
          labels: {'en': 'Call the police'},
          targetText: '',
          ttsLocale: 'de-DE',
        ),
        EmergencyPhrase(
          id: 'lost',
          labels: {'en': "I'm lost"},
          targetText: '',
          ttsLocale: 'de-DE',
        ),
        EmergencyPhrase(
          id: 'allergic',
          labels: {'en': "I'm allergic to..."},
          targetText: '',
          ttsLocale: 'de-DE',
        ),
        EmergencyPhrase(
          id: 'dont_understand',
          labels: {'en': "I don't understand"},
          targetText: '',
          ttsLocale: 'de-DE',
        ),
        EmergencyPhrase(
          id: 'where_hospital',
          labels: {'en': 'Where is the hospital?'},
          targetText: '',
          ttsLocale: 'de-DE',
        ),
        EmergencyPhrase(
          id: 'speak_slowly',
          labels: {'en': 'Please speak slowly'},
          targetText: '',
          ttsLocale: 'de-DE',
        ),
        EmergencyPhrase(
          id: 'lost_passport',
          labels: {'en': 'I lost my passport'},
          targetText: '',
          ttsLocale: 'de-DE',
        ),
      ],
    ),
    'ja': const EmergencyPhrasebook(
      languageCode: 'ja',
      languageName: 'Japanese',
      isReviewed: false,
      phrases: [
        EmergencyPhrase(
          id: 'need_doctor',
          labels: {'en': 'I need a doctor'},
          targetText: '',
          ttsLocale: 'ja-JP',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'call_police',
          labels: {'en': 'Call the police'},
          targetText: '',
          ttsLocale: 'ja-JP',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'lost',
          labels: {'en': "I'm lost"},
          targetText: '',
          ttsLocale: 'ja-JP',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'allergic',
          labels: {'en': "I'm allergic to..."},
          targetText: '',
          ttsLocale: 'ja-JP',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'dont_understand',
          labels: {'en': "I don't understand"},
          targetText: '',
          ttsLocale: 'ja-JP',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'where_hospital',
          labels: {'en': 'Where is the hospital?'},
          targetText: '',
          ttsLocale: 'ja-JP',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'speak_slowly',
          labels: {'en': 'Please speak slowly'},
          targetText: '',
          ttsLocale: 'ja-JP',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'lost_passport',
          labels: {'en': 'I lost my passport'},
          targetText: '',
          ttsLocale: 'ja-JP',
          helperLine: '',
        ),
      ],
    ),
    'ar': const EmergencyPhrasebook(
      languageCode: 'ar',
      languageName: 'Arabic',
      isReviewed: false,
      phrases: [
        EmergencyPhrase(
          id: 'need_doctor',
          labels: {'en': 'I need a doctor'},
          targetText: '',
          ttsLocale: 'ar-SA',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'call_police',
          labels: {'en': 'Call the police'},
          targetText: '',
          ttsLocale: 'ar-SA',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'lost',
          labels: {'en': "I'm lost"},
          targetText: '',
          ttsLocale: 'ar-SA',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'allergic',
          labels: {'en': "I'm allergic to..."},
          targetText: '',
          ttsLocale: 'ar-SA',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'dont_understand',
          labels: {'en': "I don't understand"},
          targetText: '',
          ttsLocale: 'ar-SA',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'where_hospital',
          labels: {'en': 'Where is the hospital?'},
          targetText: '',
          ttsLocale: 'ar-SA',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'speak_slowly',
          labels: {'en': 'Please speak slowly'},
          targetText: '',
          ttsLocale: 'ar-SA',
          helperLine: '',
        ),
        EmergencyPhrase(
          id: 'lost_passport',
          labels: {'en': 'I lost my passport'},
          targetText: '',
          ttsLocale: 'ar-SA',
          helperLine: '',
        ),
      ],
    ),
  };
}
