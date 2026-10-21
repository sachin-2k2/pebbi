/// Repository interface for translating user-entered text ("Add a phrase").
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract interface class TranslationRepository {
  /// Translates [query] into [targetLanguageCode] with meaning in [explanationLanguageCode].
  Future<String> translate({
    required String query,
    required String targetLanguageCode,
    required String explanationLanguageCode,
  });
}
