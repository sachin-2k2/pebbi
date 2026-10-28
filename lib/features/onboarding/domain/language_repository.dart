import 'language_option.dart';
import 'learnable_language.dart';

/// Repository interface for fetching available explanation/native and learnable languages.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart interface in domain layer.
abstract interface class LanguageRepository {
  /// Fetches native spoken languages from GET /api/languages/native.
  Future<List<LanguageOption>> getNativeLanguages();

  /// Fetches target learnable languages from GET /api/languages/learn?native_language=<code>.
  Future<List<LearnableLanguage>> getLearnLanguages(String nativeCode);

  /// Synchronous fallback / legacy getter.
  List<LanguageOption> getExplanationLanguages();
}
