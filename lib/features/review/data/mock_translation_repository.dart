import '../domain/translation_repository.dart';

/// Mock implementation of [TranslationRepository].
///
/// Follows AGENTS.md §1 & §6: Implements placeholder translation without network calls.
class MockTranslationRepository implements TranslationRepository {
  MockTranslationRepository({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<String> translate({
    required String query,
    required String targetLanguageCode,
    required String explanationLanguageCode,
  }) async {
    if (shouldFail) {
      throw StateError('Unable to translate phrase.');
    }
    // Simple mock heuristic returning capitalized query with language indicator
    return query.trim();
  }
}
