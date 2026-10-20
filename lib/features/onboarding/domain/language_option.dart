/// Domain model representing a selectable language option.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.badgeGlyph,
    required this.translationsReviewed,
    this.isRtl = false,
  });

  /// ISO language code (e.g., 'en', 'ar', 'es').
  final String code;

  /// Name of the language written in its own native script (e.g. 'العربية', 'हिन्दी', 'Español').
  final String nativeName;

  /// English name for search and fallback (e.g. 'Arabic', 'Hindi', 'Spanish').
  final String englishName;

  /// Small single-character script glyph shown inside the chip badge (e.g. 'A', 'ع', 'अ').
  final String badgeGlyph;

  /// Whether full lesson translations have been reviewed for launch.
  /// When false, triggers the yellow notice banner.
  final bool translationsReviewed;

  /// Whether this language is written right-to-left (e.g. Arabic, Urdu).
  final bool isRtl;

  /// Checks if this language matches a search query, ignoring case and accents.
  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    final normalizedQuery = _normalize(query);
    final normalizedNative = _normalize(nativeName);
    final normalizedEnglish = _normalize(englishName);

    return normalizedNative.contains(normalizedQuery) ||
        normalizedEnglish.contains(normalizedQuery);
  }

  /// Pure Dart diacritic and accent stripper.
  static String _normalize(String input) {
    var str = input.toLowerCase().trim();
    const accents = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'ã': 'a',
      'å': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    accents.forEach((accent, replacement) {
      str = str.replaceAll(accent, replacement);
    });
    return str;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageOption &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          translationsReviewed == other.translationsReviewed;

  @override
  int get hashCode => Object.hash(code, translationsReviewed);
}
