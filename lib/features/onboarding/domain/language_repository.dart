import 'language_option.dart';

/// Repository interface for fetching available explanation/native languages.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart interface in domain layer.
abstract interface class LanguageRepository {
  List<LanguageOption> getExplanationLanguages();
}
