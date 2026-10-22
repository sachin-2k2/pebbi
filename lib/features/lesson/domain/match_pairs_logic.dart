import 'exercise.dart';

/// Pure domain evaluation for "Match the pairs" exercises.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class MatchPairsLogic {
  /// Checks whether [targetId] and [meaningId] form a valid pair.
  static bool isPairMatch(String targetId, String meaningId) {
    return targetId == meaningId;
  }

  /// Checks whether all pairs in [exercise] have been matched.
  static bool isAllMatched({
    required MatchPairsExercise exercise,
    required Set<String> matchedPairIds,
  }) {
    return exercise.pairs.every((pair) => matchedPairIds.contains(pair.id));
  }
}
