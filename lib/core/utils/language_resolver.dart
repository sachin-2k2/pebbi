import '../../features/onboarding/data/mock_language_repository.dart';
import '../../features/onboarding/data/mock_learnable_language_repository.dart';

/// Central utility for resolving ISO language codes to English and Native names.
///
/// Follows AGENTS.md §2.1: Reusable core utility, pure Dart with zero Flutter imports.
abstract final class LanguageResolver {
  static const Map<String, (String english, String native)> _knownLanguages = {
    'ml': ('Malayalam', 'മലയാളം'),
    'en': ('English', 'English'),
    'es': ('Spanish', 'Español'),
    'fr': ('French', 'Français'),
    'de': ('German', 'Deutsch'),
    'ja': ('Japanese', '日本語'),
    'ar': ('Arabic', 'العربية'),
    'hi': ('Hindi', 'हिन्दी'),
    'ta': ('Tamil', 'தமிழ்'),
    'te': ('Telugu', 'తెలుగు'),
    'kn': ('Kannada', 'ಕನ್ನಡ'),
    'ur': ('Urdu', 'اردو'),
    'ko': ('Korean', '한국어'),
    'zh': ('Mandarin Chinese', '中文'),
    'pt': ('Portuguese', 'Português'),
    'id': ('Indonesian', 'Bahasa Indonesia'),
    'it': ('Italian', 'Italiano'),
    'ru': ('Russian', 'Русский'),
  };

  /// Resolves an ISO code to its English name (e.g. 'ml' -> 'Malayalam').
  static String resolveEnglishName(
    String? code, {
    String fallback = 'English',
  }) {
    if (code == null || code.trim().isEmpty) return fallback;
    final normalized = code.toLowerCase().trim();

    final known = _knownLanguages[normalized];
    if (known != null) return known.$1;

    const learnRepo = MockLearnableLanguageRepository();
    final learn = learnRepo
        .getLearnableLanguages()
        .where((l) => l.code == normalized)
        .firstOrNull;
    if (learn != null) return learn.englishName;

    final native = MockLanguageRepository.defaultLanguages
        .where((l) => l.code == normalized)
        .firstOrNull;
    if (native != null) return native.englishName;

    return fallback;
  }

  /// Resolves an ISO code to its native display name (e.g. 'ml' -> 'മലയാളം').
  static String resolveNativeName(String? code, {String fallback = 'English'}) {
    if (code == null || code.trim().isEmpty) return fallback;
    final normalized = code.toLowerCase().trim();

    final known = _knownLanguages[normalized];
    if (known != null) return known.$2;

    const learnRepo = MockLearnableLanguageRepository();
    final learn = learnRepo
        .getLearnableLanguages()
        .where((l) => l.code == normalized)
        .firstOrNull;
    if (learn != null) return learn.nativeName;

    final native = MockLanguageRepository.defaultLanguages
        .where((l) => l.code == normalized)
        .firstOrNull;
    if (native != null) return native.nativeName;

    return fallback;
  }
}
