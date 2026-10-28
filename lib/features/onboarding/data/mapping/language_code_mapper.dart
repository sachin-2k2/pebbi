/// Mapping and availability resolution for language codes.
///
/// Follows API-UPDATES.md §2:
/// - Target language `en` is available at launch with `has_lessons: true` and `has_placement: true`.
/// - Spanish, French, German are `coming_soon` with `has_lessons: false`.
abstract final class LanguageCodeMapper {
  static const String defaultNative = 'ml';
  static const String defaultTarget = 'en';

  /// Language codes currently supported by backend placement testing.
  static const Set<String> availablePlacementTargets = {'en', 'es', 'ml'};

  static String toApi(String? code, {String defaultCode = defaultNative}) {
    if (code == null || code.trim().isEmpty) return defaultCode;
    return code.toLowerCase().trim();
  }

  static String fromApi(String? apiCode, {String defaultCode = defaultNative}) {
    if (apiCode == null || apiCode.trim().isEmpty) return defaultCode;
    return apiCode.toLowerCase().trim();
  }

  /// Whether the target language has an available placement quiz on the backend.
  static bool hasPlacementQuiz(String targetCode) {
    return availablePlacementTargets.contains(targetCode.toLowerCase().trim());
  }
}
