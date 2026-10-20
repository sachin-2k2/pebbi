import 'learnable_language.dart';

/// Repository interface for fetching languages available to learn.
///
/// Follows AGENTS.md §1 & §2: Pure Dart interface, hides data source.
abstract interface class LearnableLanguageRepository {
  /// Returns the catalog of learnable languages, including coming soon entries.
  List<LearnableLanguage> getLearnableLanguages();
}
