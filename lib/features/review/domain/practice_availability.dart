import 'practice_mode.dart';
import 'practice_summary.dart';

/// Status indicating whether a practice room is ready to be entered.
enum PracticeAvailabilityStatus {
  available,
  unlockFirstLesson,
  noFlashcardsYet,
  noTrickyPhrases,
}

/// Evaluation result for practice room availability.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
class PracticeAvailabilityResult {
  const PracticeAvailabilityResult(this.status);

  final PracticeAvailabilityStatus status;

  bool get isAvailable => status == PracticeAvailabilityStatus.available;
}

/// Pure domain evaluation of whether a practice session can be started.
PracticeAvailabilityResult evaluatePracticeAvailability(
  PracticeMode mode,
  PracticeSummary summary,
) {
  switch (mode) {
    case PracticeMode.mix2min:
      if (summary.isMixAvailable || summary.reviewedPhraseCount > 0) {
        return const PracticeAvailabilityResult(
          PracticeAvailabilityStatus.available,
        );
      }
      return const PracticeAvailabilityResult(
        PracticeAvailabilityStatus.unlockFirstLesson,
      );

    case PracticeMode.flashcards:
      if (summary.flashcardCount > 0) {
        return const PracticeAvailabilityResult(
          PracticeAvailabilityStatus.available,
        );
      }
      return const PracticeAvailabilityResult(
        PracticeAvailabilityStatus.noFlashcardsYet,
      );

    case PracticeMode.tricky:
      if (summary.trickyCount > 0) {
        return const PracticeAvailabilityResult(
          PracticeAvailabilityStatus.available,
        );
      }
      return const PracticeAvailabilityResult(
        PracticeAvailabilityStatus.noTrickyPhrases,
      );
  }
}
