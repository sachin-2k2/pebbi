import 'phrase.dart';

/// Summary metrics derived from learned phrases.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class ReviewSummary {
  const ReviewSummary({
    required this.totalMet,
    required this.trickyCount,
    required this.newCount,
    required this.savedCount,
  });

  final int totalMet;
  final int trickyCount;
  final int newCount;
  final int savedCount;

  int get totalCount => totalMet;
  int get masteredCount => totalMet - trickyCount - newCount;

  /// Pure factory computing summary metrics from a list of [phrases].
  factory ReviewSummary.fromPhrases(List<Phrase> phrases) {
    var tricky = 0;
    var newP = 0;
    var saved = 0;

    for (final p in phrases) {
      if (p.status == PhraseStatus.tricky) tricky++;
      if (p.status == PhraseStatus.newPhrase) newP++;
      if (p.isSaved) saved++;
    }

    return ReviewSummary(
      totalMet: phrases.length,
      trickyCount: tricky,
      newCount: newP,
      savedCount: saved,
    );
  }

  static const empty = ReviewSummary(
    totalMet: 0,
    trickyCount: 0,
    newCount: 0,
    savedCount: 0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewSummary &&
          runtimeType == other.runtimeType &&
          totalMet == other.totalMet &&
          trickyCount == other.trickyCount &&
          newCount == other.newCount &&
          savedCount == other.savedCount;

  @override
  int get hashCode => Object.hash(totalMet, trickyCount, newCount, savedCount);
}
