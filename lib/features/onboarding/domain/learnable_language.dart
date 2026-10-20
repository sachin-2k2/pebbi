/// Immutable domain model representing a language available to learn or coming soon.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LearnableLanguage {
  const LearnableLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.glyph,
    required this.learnersCount,
    required this.isAvailable,
    required this.helloText,
    required this.ttsLocale,
    this.difficulty,
  });

  /// ISO 639-1 language code (e.g. 'es', 'fr', 'de').
  final String code;

  /// Name written in its native script (e.g. 'Español', '日本語', 'العربية').
  final String nativeName;

  /// English name for international display (e.g. 'Spanish', 'Japanese', 'Arabic').
  final String englishName;

  /// Large script character or glyph representing the writing system (e.g. 'Ñ', 'É', 'あ').
  final String glyph;

  /// Approximate learners count (e.g. 42000000 for 42M).
  final int learnersCount;

  /// Whether lessons are currently available for this language.
  final bool isAvailable;

  /// Greeting spoken aloud on tap (e.g. '¡Hola!').
  final String helloText;

  /// BCP 47 language/locale tag for Text-to-Speech synthesis (e.g. 'es-ES', 'ja-JP').
  final String ttsLocale;

  /// Learning difficulty rating from 1 (easiest) to 3 (hardest). Null for coming soon.
  final int? difficulty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearnableLanguage &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          nativeName == other.nativeName &&
          englishName == other.englishName &&
          glyph == other.glyph &&
          learnersCount == other.learnersCount &&
          isAvailable == other.isAvailable &&
          helloText == other.helloText &&
          ttsLocale == other.ttsLocale &&
          difficulty == other.difficulty;

  @override
  int get hashCode => Object.hash(
    code,
    nativeName,
    englishName,
    glyph,
    learnersCount,
    isAvailable,
    helloText,
    ttsLocale,
    difficulty,
  );
}
