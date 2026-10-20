import 'language_level.dart';
import 'placement_scoring_config.dart';

/// Contract for calculating suggested language level from placement results.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
/// TODO(question): Who decides placement scoring rules in production: client or backend API?
abstract interface class PlacementEvaluator {
  LanguageLevel evaluate({
    required int firstTryCorrectCount,
    required int totalQuestions,
  });
}

/// Standard rule-based evaluator using [PlacementScoringConfig] thresholds.
class StandardPlacementEvaluator implements PlacementEvaluator {
  const StandardPlacementEvaluator();

  @override
  LanguageLevel evaluate({
    required int firstTryCorrectCount,
    required int totalQuestions,
  }) {
    if (firstTryCorrectCount >= PlacementScoringConfig.expertMinCorrect) {
      return LanguageLevel.expert;
    }
    if (firstTryCorrectCount >= PlacementScoringConfig.knowABitMinCorrect) {
      return LanguageLevel.knowABit;
    }
    return LanguageLevel.little;
  }
}
