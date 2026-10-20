import '../../lesson/domain/exercise.dart';
import '../../lesson/domain/exercise_result.dart';
import 'language_level.dart';
import 'placement_evaluator.dart';
import 'placement_scoring_config.dart';

/// Immutable domain model representing placement evaluation results.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class PlacementResult {
  const PlacementResult({
    required this.suggestedLevel,
    required this.chosenLevel,
    required this.firstTryCorrect,
    required this.totalQuestions,
    this.praisePhrases = const [],
    this.streakDay,
  });

  /// Evaluates and constructs [PlacementResult] from session exercises and recorded results.
  factory PlacementResult.fromSession({
    required List<Exercise> exercises,
    required Map<String, ExerciseResult> results,
    PlacementEvaluator evaluator = const StandardPlacementEvaluator(),
    int? streakDay = 1,
  }) {
    final firstTryCount = results.values
        .where((r) => r.isFirstTryCorrect)
        .length;
    final total = exercises.length;

    final praisePhrases = <String>[];
    for (final ex in exercises) {
      final res = results[ex.id];
      if (res != null && res.isFirstTryCorrect && ex.praisePhrase != null) {
        praisePhrases.add(ex.praisePhrase!);
        if (praisePhrases.length >= PlacementScoringConfig.maxPraisePhrases) {
          break;
        }
      }
    }

    final suggestedLevel = evaluator.evaluate(
      firstTryCorrectCount: firstTryCount,
      totalQuestions: total,
    );

    return PlacementResult(
      suggestedLevel: suggestedLevel,
      chosenLevel: suggestedLevel,
      firstTryCorrect: firstTryCount,
      totalQuestions: total,
      praisePhrases: praisePhrases,
      streakDay: streakDay,
    );
  }

  /// Proficiency level evaluated by the placement quiz algorithm.
  final LanguageLevel suggestedLevel;

  /// Proficiency level currently selected by the learner (defaults to [suggestedLevel]).
  final LanguageLevel chosenLevel;

  /// Count of questions answered correctly on the very first attempt.
  final int firstTryCorrect;

  /// Total number of questions presented in the placement set.
  final int totalQuestions;

  /// Up to [PlacementScoringConfig.maxPraisePhrases] phrases answered correctly on first try.
  final List<String> praisePhrases;

  /// Day number for streak chip, or null if no streak is awarded.
  final int? streakDay;

  /// Whether the score chip ("{firstTry}/{total} first try") should be visible.
  ///
  /// TODO(question): The placement intro promised "No scores, no shaming" and
  /// "You never see a fail". Should the score chip be hidden for low scores (e.g. <= 3)?
  /// Currently shown always.
  bool get isScoreChipVisible => true;

  /// Whether the streak chip should be displayed.
  bool get isStreakChipVisible => streakDay != null && streakDay! > 0;

  /// Whether the praised phrases card should be displayed.
  bool get hasPraisePhrases => praisePhrases.isNotEmpty;

  PlacementResult copyWith({
    LanguageLevel? suggestedLevel,
    LanguageLevel? chosenLevel,
    int? firstTryCorrect,
    int? totalQuestions,
    List<String>? praisePhrases,
    int? streakDay,
  }) {
    return PlacementResult(
      suggestedLevel: suggestedLevel ?? this.suggestedLevel,
      chosenLevel: chosenLevel ?? this.chosenLevel,
      firstTryCorrect: firstTryCorrect ?? this.firstTryCorrect,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      praisePhrases: praisePhrases ?? this.praisePhrases,
      streakDay: streakDay ?? this.streakDay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacementResult &&
          runtimeType == other.runtimeType &&
          suggestedLevel == other.suggestedLevel &&
          chosenLevel == other.chosenLevel &&
          firstTryCorrect == other.firstTryCorrect &&
          totalQuestions == other.totalQuestions &&
          streakDay == other.streakDay &&
          _listEquals(praisePhrases, other.praisePhrases);

  @override
  int get hashCode => Object.hash(
    suggestedLevel,
    chosenLevel,
    firstTryCorrect,
    totalQuestions,
    streakDay,
    Object.hashAll(praisePhrases),
  );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
