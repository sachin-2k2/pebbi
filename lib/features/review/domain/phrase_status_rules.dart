import 'phrase.dart';

/// Pure domain rules interface determining phrase status (tricky, new, or none).
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
///
/// TODO(question: determine whether spaced-repetition status rules are client-calculated or server-provided).
abstract interface class PhraseStatusRules {
  PhraseStatus evaluate({
    required int seenCount,
    required int wrongCount,
    required DateTime? lastSeen,
  });

  PhraseStatus determineStatus({
    required int box,
    required int timesSeen,
    required int timesCorrect,
  });
}

/// Default placeholder implementation of [PhraseStatusRules].
///
/// Heuristic:
/// - Any phrase with wrongCount >= 2 is considered [PhraseStatus.tricky].
/// - Any phrase with seenCount <= 2 and wrongCount < 2 is considered [PhraseStatus.newPhrase].
/// - Otherwise [PhraseStatus.none].
class DefaultPhraseStatusRules implements PhraseStatusRules {
  const DefaultPhraseStatusRules();

  @override
  PhraseStatus evaluate({
    required int seenCount,
    required int wrongCount,
    required DateTime? lastSeen,
  }) {
    if (seenCount > 0 && wrongCount >= 2) {
      return PhraseStatus.tricky;
    }
    if (seenCount <= 2) {
      return PhraseStatus.newPhrase;
    }
    return PhraseStatus.none;
  }

  @override
  PhraseStatus determineStatus({
    required int box,
    required int timesSeen,
    required int timesCorrect,
  }) {
    if (box >= 3) return PhraseStatus.mastered;
    if (timesSeen > 0 && (timesCorrect / timesSeen) < 0.6) {
      return PhraseStatus.tricky;
    }
    if (timesSeen <= 2) return PhraseStatus.newPhrase;
    return PhraseStatus.none;
  }
}
